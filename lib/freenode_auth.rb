require 'monitor'
require './util'
require 'time'

module Auth

# Hooray for completely breaking encapsulation!
attr_accessor :reg_date_data, :ready, :r_state, :r_sig, :reg_date_lambda
module_function :reg_date_data,:reg_date_data=, :ready,:ready=
module_function :r_state,:r_state=, :r_sig,:r_sig=
module_function :reg_date_lambda,:reg_date_lambda=

attr_accessor :authname_lambda
module_function :authname_lambda,:authname_lambda=

attr_accessor :alist;
module_function :alist,:alist=

@ulist = {}
attr_accessor :ulist;
module_function :ulist,:ulist=

@reg_date_data = {}
@reg_date_data.extend(MonitorMixin)
@ready = @reg_date_data.new_cond

@r_state = [0]
@r_state.extend(MonitorMixin)
@r_sig = @r_state.new_cond

def Auth.fetch_reg_date(target)
  Auth.reg_date_lambda.call target
end

def Auth.fetch_authname(target)
  Auth.authname_lambda.call(target)
end

FreenodeLogout = lambda do |context, user|
  if @ulist.has_key?(user.nick)
    @ulist.delete(user.nick)
  end
end

FreenodeNick = lambda do |nick1, nick2|
  if @ulist.has_key?(nick1)
    @ulist[nick2]=@ulist[nick1]
    @ulist.delete nick1
    return true
  else return false; end; end;


end

fuck_concurrency = Mutex.new

on_cinch_init do

  Auth.reg_date_lambda = lambda do |target|
    fuck_concurrency.lock
    User("NickServ").send("info #{target}")
    Auth.reg_date_data.synchronize do
      Auth.ready.wait_until { Auth.reg_date_data.has_key? target }
      target = Auth.reg_date_data.delete target
    end
    fuck_concurrency.unlock; target;
  end

  on :message, /^@get_ns_data (.+)$/ do |context, target|
    context.reply Auth.fetch_reg_date(target)
  end

  our_date=''; our_name='';  

  on :notice do |context|
    if context.user != nil and context.user.nick == "NickServ"
      line = strip_formatting(context.message)
      if match = /^Information on (.+?) \(account (.+?)\):$/.match(line)
        Auth.r_state.synchronize do
          Auth.r_sig.wait_until { Auth.r_state[0] == 0 }
          our_name=match[2];
          Auth.r_state[0] = 1;
          Auth.r_sig.broadcast;
        end;
      end;
      if match = /^Registered : (.+?) \(/.match(line)
        Auth.r_state.synchronize do
          Auth.r_sig.wait_until { Auth.r_state[0] == 1 }
          our_date = match[1]; 
          Auth.r_state[0] = 2
          Auth.r_sig.broadcast
        end;
      end;
      if match = /^\*\*\* End of Info \*\*\*$/.match(line)
        Auth.r_state.synchronize do
          Auth.r_sig.wait_until { Auth.r_state[0] == 2 }
          Auth.reg_date_data.synchronize do
            Auth.reg_date_data[our_name]=our_date
            our_name=our_date=''
            Auth.ready.broadcast
          end; 
          Auth.r_state[0] = 0
          Auth.r_sig.broadcast
        end;
      end;
    end;
  end
  
  Auth.authname_lambda = lambda do |target|
    user = User(target)
    user.whois
    while !user.synced?(:authname) do
      sleep(0.1)
    end
    return user.authname
  end

  on :channel do |context|
   unless Auth.alist.has_key?(context.user.nick)
    unless Auth.ulist.has_key?(context.user.nick) and (Time.now.utc-Auth.ulist[context.user.nick]<1000)
     authname = Auth.fetch_authname(context.user.nick)
     if authname
      match = Auth::Resident[:name => authname]
      unless match
       r = Auth::Resident.new;
       r.name=authname; r.identifier=Auth.fetch_reg_date(authname); r=r.save;
       Auth.alist[context.user.nick]=r
      else
       if Auth.fetch_reg_date(authname) == match.identifier
        Auth.alist[context.user.nick]=match;
       elsif match.identifier!='password'
        context.reply('Registration no longer valid. Creating new one.')
        match.delete; 
        r = Auth::Resident.new;
        r.name=authname; r.identifier=Auth.fetch_reg_date(authname); r=r.save;
        Auth.alist[context.user.nick]=r
       else
        context.reply('Registration no longer valid. Overriding password account for network authentication.')
        match.delete; 
        r = Auth::Resident.new;
        r.name=authname; r.identifier=Auth.fetch_reg_date(authname); r=r.save;
        Auth.alist[context.user.nick]=r
       end
      end
     else Auth.ulist[context.user.nick]=Time.now.utc; end;
    end
   end
  end

  on :leaving do |context, user| Auth::FreenodeLogout.call context, user; end
  on :nick do |info|
    Auth::FreenodeNick.call info.user.last_nick, info.user.nick
  end
  

end
