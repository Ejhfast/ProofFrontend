class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def verify_proof
    
    @failure = nil
    @previous_lines = []
    no_new_line = false
    @last_node = Node.root(@assignment.id)
    @prooflines =  @proof.prooflines.cache.sort_by{|p| p.created_at } rescue @proof.prooflines
        
    if @proof && @prooflines
      @prooflines.select{|x| x.hash_str != ""}.sort_by{|p| p.created_at}.each do |p|
        # Check if we have a node for this proofline, based on its parent (what came before is important)
        @node = Node.lookup(@last_node, p.hash_str)
        if @node
          @node.count = @node.count + 1
          @node.save!
          @last_node = @node
          #if(@node.valid || Node.check_hash(p.hash_str, @assignment.id))
          if @node.valid
            p.proven = true
            p.save!
            if remove_whitespace(p.conclusion) == remove_whitespace(@assignment.goal)
              @proof.finished = true
              @proof.save!
            end
            @previous_lines += [p.conclusion]
          else
            p.syntax_error = @node.syntax_error
            p.proven = false
            p.save!
            no_new_line = true
            @failure = "Could not prove <b>" + p.conclusion + "</b>."  #need to refactor this stuff appears in two places
          end
          
        else # We haven't seen this proofline before, need to prove it
          rulesets = compose_rulesets(@assignment.rulesets.select{|x| x.free == false && x.name == p.ruleset})

          match_assumps = @assignment.assumptions.select{|x| p.assumptions.include?(x.name)}.map{|x| x.name}
          match_prev_lines = @previous_lines.select{|x| p.assumptions.include?(x)}
          assumptions = compose_assumptions((match_assumps+match_prev_lines).uniq)

          syntax = compose_syntax(@assignment)
          frees = compose_rulesets(@assignment.rulesets.select{|x| x.free})

          params = {"rulesets" => rulesets, "assumptions" => assumptions, "syntax" => syntax, "conclusion" => p.conclusion, "frees" => frees }
          logger.info 'Submitting request to backend: ' + params.to_s

          x = Net::HTTP.post_form(URI.parse('http://test-proof-backend.herokuapp.com/check_proof'), params)
          logger.info 'Backend response: ' + x.body
          resp = x.body

          if x && x.body =~ /Proved/
            p.proven = true
            p.syntax_error = false
            p.save!
            if remove_whitespace(p.conclusion) == remove_whitespace(@assignment.goal)
              @proof.finished = true
              @proof.save!
            end
            @previous_lines += [p.conclusion]            
          else
            if x && x.body =~ /Failure: Error parsing conclusion/
              p.syntax_error = true
            else
              p.syntax_error = false
            end
            p.proven = false
            p.save!
            no_new_line = true
            @failure = "Could not prove <b>" + p.conclusion + "</b>. " + resp
          end
          p.save!
          
          @last_node = Node.register(@last_node,p,p.proven,p.syntax_error,p.hash_str) #build new node to reflect what we've learned
          
        end
      end
      @proof.reload.prooflines rescue true
    end
    
    @prooflines.push(Proofline.new) unless no_new_line || @proof.finished
    
    generate_selections
    
    if @proof.finished && current_user.external
      submit_success
    end
    
  end
  
  def generate_selections
    @previous_lines = @previous_lines || []
    @select_rulesets = [["Free Rule","1fds*kslng8"]]+@assignment.rulesets.select{|x| x.free == false}.map{|rs| [rs.name, rs.name]}
    # Display assumptions selection in reverse order, placing more recent steps at the head of the list
    @select_assumptions = ((@assignment.assumptions.map{|as| [as.name, as.name]} + @previous_lines.map{|x| [x,x]}).uniq).reverse
  end
  
  def get_session_state(nid = nil, pid = nil)
    session[:node_id] = nid || params[:node_id]
    session[:parent_id] = pid || params[:parent_id]
  end
  
  def compose_rulesets rulesets
    out = ""
    rulesets.each do |rs|
      out += rs.name + "{"
      rs.rules.each do |rule|
        out +=  "("+rule.lhs + rule.gen_type + rule.rhs + ")"+ rs.constraints_string + ";"
      end
      out += "}"
    end
    out
  end
  
  def compose_assumptions assumptions
    out = ""
    count = 0
    assumptions.each do |as|
      out += "A" + count.to_s + ": " + as + ";" 
      count = count + 1
    end
    out
  end
  
  def compose_syntax assignment
    if assignment.syntaxes == []
      return ""
    end
    out = "["
    assignment.syntaxes.each do |s|
      out += "(\""+s.name.to_s+"\","+s.args.to_s+"),"
    end
    out = out.first(out.size - 1)
    out += "]"
    out
  end
  
  def remove_whitespace str
    str.split(" ").join
  end

  def submit_success
    if session[:stanford]
      @url = URI.parse('https://stanford.coursera.org/compilers/assignment/api/update_score')
    else
      @url = URI.parse('https://class.coursera.org/compilers/assignment/api/update_score')
    end
    @http = Net::HTTP.new(@url.host, @url.port)
    @http.use_ssl = true
    @request = Net::HTTP::Post.new(@url.request_uri)
    @request['x-api-key'] = ENV['COMPILERS_API']
    @form_data = { 'user_id' => current_user.ext_id, 'assignment_part_sid' => @assignment.id.to_s, 'score' => 1, 'feedback' => ''} 
    @form_data['create_new_submission'] = 1
    @request.set_form_data(@form_data)
    @response = @http.request(@request)
    @results = ActiveSupport::JSON.decode(@response.body)
#TODO flash messages showing success/failure?
    if @results['status'] != "202"
      logger.info 'Error submitting results! status code: ' + @response.code + ', body: ' + @results.to_s + ', assignment_id: ' + @assignment.id.to_s + ', user_id: ' + current_user.ext_id
    else
      logger.info 'Successfully submitted results to Coursera for user ' + current_user.ext_id + ', assignment_id ' + @assignment.id.to_s
    end
  end
  
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  def login
    if params["message"]
      external_sign_in
    else
      session[:return_to] = request.url
    end

    if current_user
      session.delete :return_to
    else
      redirect_to '/sign_in'
    end
  end

  def external_sign_in
    begin
# Decrypt message sent by Coursera
      @cipher = OpenSSL::Cipher::Cipher.new('aes-256-cbc')
      @cipher.key = ENV['CIPHER_KEY']
      @cipher.iv = ENV['CIPHER_IV']
      @decrypt = @cipher.update(Base64.decode64(params["message"]))
      @decrypt << @cipher.final
      @mapping = ActiveSupport::JSON.decode(@decrypt)
# Need to check if user exists first!
      user = User.where(ext_id: @mapping["user_id"]).first
    rescue
      flash[:error] = "Bad message received, try again."
    end
    if user
      session[:user_id] = user.id
      flash[:success] = "Logged in!"
      finish_login
    else
# Create new user
      @userdata = {}
      @userdata["name"] = @mapping["full_name"]
      @userdata["ext_id"] = @mapping["user_id"]
      @userdata["external"] = true
      @user = User.new(@userdata)
      if(@user.save)
        session[:user_id] = @user.id
        flash[:success] = "Logged in!"
        finish_login
      end
    end
  end

  def finish_login
    if session[:return_to]
      @redirect = session[:return_to]
      session.delete :return_to
      redirect_to @redirect
    end
  end
  
  helper_method :current_user
  
end
