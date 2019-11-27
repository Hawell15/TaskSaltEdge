require 'watir'
class Bank
  attr_accessor :browser

  def openAccountPage
    @browser=Watir::Browser.new
    @browser.goto("https://wb.micb.md/way4u-wb/");
    login=""
    password=""
    username=@browser.text_field(:class=>"username")
    username.exists?
    username.set login
    username.value
    pass=@browser.text_field(id:"password")
    pass.exists?
    pass.set password
    pass.value
    @browser.button(:class=>"wb-button").click
  end
end

bank=Bank.new
bank.openAccountPage
