require "spec_helper"

#Setup test specific ApplicationController
class Account; end # this is so the spec will work in isolation

class ApplicationController < ActionController::Base
  include Rails.application.routes.url_helpers
  set_current_tenant_by_subdomain_or_domain
end

# Start testing
describe ApplicationController, :type => :controller do
  controller do
    def index
      render :text => "custom called"
    end
  end

  it 'Finds the correct tenant with a example1.com' do
    @request.host = "example1.com"
    Account.should_receive(:where).with({subdomain: nil}) {[]}
    Account.should_receive(:where).with({domain: 'example1.com'}) {['account1']}
    get :index
    ActsAsTenant.current_tenant.should eq 'account1'
  end

  it 'Finds the correct tenant with a subdomain.example.com' do
    @request.host = "subdomain.example.com"
    Account.should_receive(:where).with({subdomain: 'subdomain'}) {['account1']}
    get :index
    ActsAsTenant.current_tenant.should eq "account1"
  end

  it 'Finds the correct tenant with a www.subdomain.example.com' do
    @request.host = "subdomain.example.com"
    Account.should_receive(:where).with({subdomain: 'subdomain'}) {['account1']}
    get :index
    ActsAsTenant.current_tenant.should eq "account1"
  end


end