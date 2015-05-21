module ViewHelper
  def insert_auth_token
    html = <<-HTML 
      <input type="hidden" 
             name="authenticity_token" 
             value="#{session['authenticity_token']}">
      HTML
    html
  end
end