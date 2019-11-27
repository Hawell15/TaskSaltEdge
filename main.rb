require 'watir'
require_relative 'accounts'
class Bank
  attr_accessor :browser, :accounts_array

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

public def accountInfoExtract
@browser.div(:class=>"block__main-menu").wait_until(&:present?)
@browser.span(:text=>"Carduri și conturi").click
@browser.div(:class=>"contracts-section").wait_until(&:present?)
@browser.link(:class=>"archiveLink").click
@accounts_array=Array.new
@browser.divs(:class=>"main-info").map do |acc|
  @accounts_array.push(Accounts.new(
    acc.link(:class=>"name").title,
    acc.div(:class=>["icon", "icon-account "]).text,
    acc.span(:class=>"amount").text))
  end
end


bank=Bank.new
bank.openAccountPage
bank.accountInfoExtract
