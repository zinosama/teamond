require 'test_helper'

class UserTest < ActiveSupport::TestCase
	
	def setup 
		@admin = users(:zino)
		@user = User.new(name: "Test User", email: "user@example.com", phone: "5853231234", password: "foobar", password_confirmation: "foobar")
	end

	test 'should be valid' do 
		@user.valid?
	end

	test 'name should be present' do
		@user.name = "  "
		assert_not @user.valid?
	end

	test 'name should not be too long' do
		@user.name = 'a' * 51
		assert_not @user.valid?
	end

	test 'email should be present' do
		@user.email = "   "
		assert_not @user.valid?
	end

	test 'email should not be too long' do
		@user.email = 'a' * 256 + "@example.com"
		assert_not @user.valid?
	end

	test 'email should accept valid addresses' do
		valid_addresses = %w[user@example.com USER@foo.com A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
		valid_addresses.each do |valid_address|
			@user.email = valid_address
			assert @user.valid?, "#{valid_address.inspect} should be valid"
		end
	end

	test 'email should reject invalid addresses' do
		invalid_addresses = %w[user@example,com user_at_foo.org user. name@example. foo@bar_baz.com foo@bar+baz.com]
		invalid_addresses.each do |invalid_address|
			@user.email = invalid_address
			assert_not @user.valid?, "#{invalid_address.inspect} should be valid"
		end
	end

	test 'email should be unique' do
		duplicate_user = @user.dup
		@user.save
		assert_not duplicate_user.valid?
	end

	test 'email should be saved in lowercase' do
		@user.email = "ABC@example.com"
		@user.save
		assert_equal("abc@example.com", @user.reload.email)
	end

	#password tests
	test 'password should be present' do
		@user.password = @user.password_confirmation = " " * 6
		assert_not @user.valid?
	end

	test 'password should have a minimum length' do
		@user.password = @user.password_confirmation = "a" * 5
		assert_not @user.valid?
	end

	#authenticated? method test
	test 'authenticated? should return false when argument is nil' do
		assert_not @user.authenticated?(:remember, '')
	end

	test 'phone should not be too long' do
		@user.phone = "1" * 26
		assert_not @user.valid?
	end

	test 'wechat should not be too long' do
		@user.wechat = "a" * 51
		assert_not @user.valid?
	end 

	test 'role is default to shopper' do
		@user.save
		assert @user.reload.role.is_a? Shopper
	end

	test 'can be valid admin' do
		# @current_user = @admin
		@user.role = Admin.new(user: @user)
		assert @user.save
		assert @user.reload.role.is_a? Admin
	end

	test 'can be driver' do
		@user.role = Driver.new(user: @user)
		@user.save
		assert @user.role.is_a? Driver
	end

	test 'can be provider' do
		store = Store.create(name: "store1", address: "address")
		@user.role = Provider.new(store: store, user: @user)
		@user.save
		assert @user.role.is_a? Provider
	end

	test 'role cannot be changed' do 
		@user.save
		assert @user.role.is_a? Shopper
		assert_no_difference 'Admin.count' do
			@user.role = Admin.create(user: @user)
		end
		assert_not @user.save
	end
end
