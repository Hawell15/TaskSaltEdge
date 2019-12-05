require 'watir'
require 'nokogiri'
require_relative 'accounts'
require_relative 'transactions'

class Bank
  attr_accessor :browser, :accounts_array

  def openAccountPage
    @browser = Watir::Browser.new
    @browser.goto("https://wb.micb.md/way4u-wb/");
    login = ""
    password = ""
    username = @browser.text_field(:class=>"username")
    username.exists?
    username.set login
    username.value
    pass = @browser.text_field(id:"password")
    pass.exists?
    pass.set password
    pass.value
    @browser.button(:class=>"wb-button").click
  end


  public def accountInfoExtract
    @browser.div(:class=>"block__main-menu").wait_until(&:present?)
    @browser.span(:text=>"Carduri și conturi").click
    @browser.div(:class=>"contracts-section").wait_until(&:present?)
    @accounts_array=Array.new

    doc = Nokogiri::HTML.parse(@browser.html)
    doc.css("div.main-info").each do |acc|
      name = acc.css("a.name").text
      currency = acc.css("div.icon.icon-account").text
      amount = acc.css("span.amount")[0].text
      account = Accounts.new(name,currency,amount)
      @accounts_array.push(account)
    end
    @browser.divs(:class=>"main-info").map do |acc|
      name = acc.link(:class=>"name").title
      acc.link(:class=>"name").click
      @browser.link(:href=>"#contract-history").wait_until(&:present?).click
      sleep 3
      setPeriod
      @transaction_array= Array.new
      account = @accounts_array.detect{|a| a.name.casecmp?(name)}
      transactionsInfoByAccountExtract(name,account)
      account.transactions=@transaction_array
      @browser.span(:text=>"Carduri și conturi").click
      @browser.div(:class=>"contracts-section").wait_until(&:present?)
    end
  end

  def setPeriod
    @browser.link(:href=>"#contract-history").wait_until(&:present?).click
    @browser.div(:class=>"filters").wait_until(&:present?)
    time = Date.today << 2
    @browser.input(:name=>"from").click
    i = 1
    @browser.div(:class=>"ui-datepicker-title ").browser.divs(:class=>"arrow").map do |arrow|
      if i == 3 then
        break
      elsif i == 2 then
        arrow.wait_until(&:present?).click
        @browser.li(:text=>(time.year).to_s).click
      end
      i += 1
    end
    @browser.div(:class=>"ui-datepicker-title ").div(:class=>"arrow").wait_until(&:present?).click
    @browser.li("data-option-array-index"=>(time.month-1).to_s).click
    @browser.link(:text=>time.day.to_s).click
    sleep 2
  end

  def transactionsInfoByAccountExtract(acc,account)
    if @browser.link(:class=>"operation-details").exists?
      @browser.spans(:class=>"history-item-description").map do |trans|
        data, description, amount, currency=transactionsInfoExtract(trans)
        @transaction_array.push(Transactions.new(data, description, amount, currency, acc))
      end
    end
  end

  def transactionsInfoExtract(trans)
     trans.link(:class=>"operation-details").wait_until(&:present?).click
     @browser.div(:class=>"details-section").wait_until(&:present?)
     details = Nokogiri::HTML.parse(@browser.html)
     data = details.css("div.details-section")[0].css("div.value").text
     account_name = details.css("div.details-section")[1].css("div.value").text
     description = details.css("div.details-section")[2].css("div.value").text
     amount = details.css("div.details-section.amounts").css("span.amount")[0].text
     currency = details.css("div.details-section.amounts").css("span.amount.currency").text
     @browser.send_keys :escape
     return data, description, amount, currency, account_name
  end

  def printAccount
    @accounts_array.each do |account|
      account.print
    end
  end

end

bank = Bank.new
bank.openAccountPage
bank.accountInfoExtract
bank.printAccount
