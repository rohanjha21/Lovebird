# curl -X POST -H "Content-Type: application/json" -d '{
#   "setting_type" : "call_to_actions",
#   "thread_state" : "existing_thread",
#   "call_to_actions":[
#     {
#       "type":"postback",
#       "title":"All Events",
#       "payload":"MORE_ALL_EVENTS_0"
#     },
#     {
#       "type":"postback",
#       "title":"My Events",
#       "payload":"MY_EVENTS"
#     },
#     {
#       "type":"postback",
#       "title":"Help",
#       "payload":"HELP"
#     }
#   ]
# }' "https://graph.facebook.com/v2.6/me/thread_settings?access_token=EAANT2k7GtasBADWMzmyTUyc59MQZCxpJWfQWFTvwsjvF3rrU97nniUD8Ov93LzDdHFtNleEMHg8AvuvGU2vf4y3FosPvI9cQ1ID1rMe52QZCZAMywQ8ZAhZBltzXwcSk0MeuEBUqfLYT16aM0LsOG8QCf0okD7vrCbPNnVqzhYwZDZD"    
require 'json'

def create_user(message)
	access = ENV['ACCESS_TOKEN']
	user_id = message.sender["id"]
	output =`curl -X GET https://graph.facebook.com/v2.6/#{user_id}?access_token=#{access}`
	info = JSON.parse(output)
	if User.find_by(facebook_id: user_id)
		User.find_by(facebook_id: user_id).destroy
	end

	 User.create(facebook_id: user_id, first_name: info["first_name"].downcase, last_name: info["last_name"].downcase, pro_pic: info["profile_pic"]) 
end

def create_relationship(user_id, crush_first_name, crush_last_name)
	if Relationship.find_by(user_id: user_id)
		Relationship.find_by(user_id: user_id).destroy
	end

	users = User.where(first_name: crush_first_name, last_name: crush_last_name)
	if not users.empty?
	    # users.each do |user|
	    #   Bot.deliver(
	    #     recipient: message.sender,
	    #     message: {
	    #       attachment: {
	    #         type: 'image',
	    #         payload:{
	    #           url: users[0].pro_pic
	    #         }
	    #       }
	    #     }
	    #   )
	    # end 
	   	Relationship.create(user_id: user_id, crush_id: users[0].facebook_id, status: 0, first_name: crush_first_name, last_name: crush_last_name)
		return users[0].facebook_id
	else
		Relationship.create(user_id: user_id, crush_id: nil, status: 1, first_name: crush_first_name, last_name: crush_last_name)
		return false
	end
end

def check_match(user_id, crush_id)
	if Relationship.find_by(user_id: user_id).pluck(:crush_id) == Relationship.find_by(user_id: crush_id).pluck(:crush_id)
		return true
	else
		return false
	end
end



