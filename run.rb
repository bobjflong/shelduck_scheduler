require 'rufus-scheduler'
require 'mail'

puts "I will run shelduck periodically. Please feel free to kill me, but please restart me!"

options = { :address              => "smtp.gmail.com",
            :port                 => 587,
            :domain               => 'smtp.gmail.com',
            :user_name            => ENV['shelduck_email_username'],
            :password             => ENV['shelduck_email_password'],
            :authentication       => 'plain',
            :enable_starttls_auto => true  }

Mail.defaults do
  delivery_method :smtp, options
end

def success?(x)
  !x.include?('Bad topic')
end

def mail(s)
  Mail.deliver do
       to ENV['shelduck_email_recipient']
     from "#{ENV['shelduck_email_username']}@gmail.com"
  subject 'shelduck results' + (success?(s) ? '' : ' [failure] ') + Time.new.inspect
     body s
  end
end

scheduler = Rufus::Scheduler.new

scheduler.interval '30m' do
  puts "Running!"
  result = nil
  2.times do
    result = `cd ~/shelduck-master && stack exec shelduck intercom`
    break if success?(result)
    puts "Unsuccessful run"
  end
  result.gsub!(/\[0m/, '')
  result.gsub!(/\[3.m/, '')
  result.gsub!(/\[38;5;.m/, '')
  mail result
  puts "Finished!"
end

scheduler.join
