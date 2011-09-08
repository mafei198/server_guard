require 'guard'
#此文件为服务器监控配置文件
#需要先配置邮件账户,且发件账户仅支持gmail,经测试收件人最好不要用qq邮箱，容易丢件
Guard.mail_config do |conf|
  #发件人账户
  conf.send_account = 'savin.notify@gmail.com'
  #发件人密码
  conf.password     = 'notify1988'
  #收件人账户
  conf.to_account   = 'mafei@nibirutech.com'
  conf.subject      = "Your server crashed."
end

Guard.dogs do |dog|
  #检测unicorn
  dog.watch do |p|
    p.name = 'unicorn'
    p.start = "/usr/bin/unicorn -c /var/www/apps/game003/current/config/unicorn.rb -E production -D"
    p.stop  = "/bin/kill -QUIT `cat /var/www/apps/game003/current/tmp/pids/unicorn.pid`"
    p.condition = "curl http://localhost:3030"
    p.timeout = 5 #连续5次重启失败发送邮件提醒，退出监控
    p.watch_blank = 10 #每隔10秒钟扫描一次服务
    p.alert_content = "003 server's unicorn service crashed at #{Time.now}"
  end

  #检测ngnix
  dog.watch do |p|
    p.name = 'ngnix'
    p.start = "sudo /etc/init.d/nginx start"
    p.stop  = "sudo /etc/init.d/nginx stop"
    p.condition = "curl http://localhost:80"
    p.timeout = 5 #连续5次重启失败发送邮件提醒，退出监控
    p.watch_blank = 10 #每隔10秒钟扫描一次服务
    p.alert_content = "003 server's ngnix service crashed at #{Time.now}"
  end
end
