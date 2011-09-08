require 'rubygems'
require 'gmail'

class Task
  attr_accessor :name, :start, :stop, :condition, :timeout, :alert_content, :watch_blank
end

class MailConf
  attr_accessor :send_account, :password, :to_account, :subject
end

class Guard
  @jobs = []
  @mail_conf = MailConf.new
  def self.dogs
    yield self
    start
  end

  def self.mail_config
    yield @mail_conf
  end

  def self.watch
    p = Task.new
    if block_given?
      yield p
    else
      raise 'need viriable!'
    end
    @jobs << Thread.new do
      i = 0
      loop do
        sleep(p.watch_blank)
        unless system(p.condition)
          i += 1
          system p.stop
          system p.start
        else
          i = 0
        end
        if i >= p.timeout
          send_mail p.alert_content
          break
        end
      end
    end
  end

  def self.start
    @jobs.each{|job|job.join}
  end

  def self.send_mail(mail_content)
    loop do
      sleep(1)
      begin
        gmail = Gmail.new(@mail_conf.send_account, @mail_conf.password)
        email = gmail.generate_message do
          to @mail_conf.to_account
          subject @mail_conf.subject
          body mail_content
        end
        gmail.deliver(email)
        break
      rescue Exception => e
      end
    end
  end
end
