class HTTPFO
  include HTTParty
  
  base_uri "www.fantasy-mmorpg.com"
  default_timeout 30
  
  def method_missing(meth, *args, &block)
    self.class.send(meth, *args, &block)
  end
  
  def dom(resp)
    Nokogiri::HTML(data)
  end
  
  def get(url, *args)
    resp = self.class.get(url, *args)
    dom(resp)
  end
  
  def updateCookies(resp)
    return unless resp.headers["set-cookie"]
    
    resp.headers.to_h["set-cookie"].each do |c|
      c.scan(/^([^=]+)=([^;]+)/i)
      cookies($1 => $2)
    end
  end
  
  def fetchAuthHash(name, password)
    resp = self.class.get("/inc/rpc/login.php", query: {
      username: name,
      password: md5(password),
      _: Time.now.to_i,
    })
    
    if resp.body == "1"
      updateCookies(resp)
      
      resp = self.class.get("/", query: {
        server: "FO03",
        x: 94,
        y: 31,
      })
      updateCookies(resp)
      
      resp = self.class.post("/inc/rpc/validate.php")
      headers("Content-Type" => "application/x-www-form-urlencoded")
      
      return resp.response.body.scan(/../).map { |x| x.hex.chr }.join.split("|").last if resp.response.body.size > 0
      
      false
    end
  end
end