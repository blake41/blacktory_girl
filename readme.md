Implementing an api like so:
```ruby
FactoryGirl.define do 
	factory :user do
		first_name "blake"
		last_name "johnson"
	end
end

user = FactoryGirl.create(:user)
puts user.first_name
puts user.last_name
```