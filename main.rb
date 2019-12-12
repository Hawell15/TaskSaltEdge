require 'watir'
require 'nokogiri'
require_relative 'accounts'
require_relative 'transactions'

class Bank

  def execute
    connect
    fetch_accounts
    fetch_transactions
    printAccount
  end

  def connect

    @browser = Watir::Browser.new
    url = "https://wb.micb.md/way4u-wb/"
    @browser.goto(url);

    login = gets.chomp.to_s
    password = gets.chomp.to_s

    username = @browser.text_field(class: "username")
    username.exists?
    username.set login
    username.value

    pass = @browser.text_field(id: "password")
    pass.exists?
    pass.set password
    pass.value

    @browser.button(:class=>"wb-button").click

  end

  def fetch_accounts

    @browser.div(:class=>"block__main-menu").wait_until(&:present?)
    @browser.span(:text=>"Carduri și conturi").click
    @browser.div(:class=>"contracts-section").wait_until(&:present?)

    @accounts = parse_accounts(Nokogiri::HTML(@browser.html))

  end

  def parse_accounts(html)

    accounts_array=[]
    html.css("div.main-info").each do |acc|
      name = acc.css("a.name").text
      currency = acc.css("div.icon.icon-account").text
      amount = acc.at_css("span.amount").text.to_f
      account = Accounts.new(name,currency,amount)
      accounts_array << account
    end
    return accounts_array
  end

  def fetch_transactions
    @browser.divs(:class=>"main-info").map do |acc|
      name = acc.link(:class=>"name").title
      acc.link(:class=>"name").click
      @browser.link(:href=>"#contract-history").wait_until(&:present?).click

      sleep 3

      setPeriod

      account = @accounts.detect{|detected_account| detected_account.name.casecmp?(name)}

      transactionsInfoByAccountExtract(name,account)

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
      trans.link(:class=>"operation-details").wait_until(&:present?).click
      @browser.div(:class=>"details-section").wait_until(&:present?)
      parse_transactions(account,Nokogiri::HTML(@browser.html))
      end
    end
  end

 def parse_transactions(account, html)
     data = html.at_css("div.details-section").at_css("div.value").text
     account_name = html.css("div.details-section")[1].css("div.value").text
     description = html.css("div.details-section")[2].css("div.value").text
     amount = html.css("div.details-section.amounts").at_css("span.amount").text
     currency = html.css("div.details-section.amounts").css("span.amount.currency").text

     account.transactions<< Transactions.new(data, description, amount, currency, account.name)
     @browser.send_keys :escape

  end

  def printAccount
    @accounts.each do |account|
      account.print
    end
  end

end

bank = Bank.new
bank.execute
