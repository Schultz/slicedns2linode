#!/usr/bin/env ruby
require 'rubygems'
require 'active_resource'
require 'logger'
require 'linode'

$LOG = Logger.new($stdout)

def error(message)
  $LOG.fatal(message)
  exit
end

SLICEHOST_API_KEY = "SLICEHOST API KEY"
LINODE_API_KEY = "LINODE API KEY"
EMAIL_ADDRESS = "SOA Email address for Linode" #required for linode.com

class Zone < ActiveResource::Base
  self.site = "https://#{SLICEHOST_API_KEY}@api.slicehost.com"
  def records
    Record.find(:all, :params => { :zone_id => self.id })
  end
  
  def self.exists?(name)
    !Zone.find(:all, :params => { :origin => name}).empty?
  end
  
  def self.find_by_name(name)
    Zone.find(:first, :params => { :origin => name })
  end
  
  def domain
      origin.sub(/\.$/,'')
  end  
end

class Record < ActiveResource::Base
  self.site = "https://#{SLICEHOST_API_KEY}@api.slicehost.com"

  def kind
    record_type.downcase
  end

  [:a,:mx,:cname,:srv,:ns,:txt].each do |kind|
    define_method "#{kind}?" do
      self.kind == "#{kind}"
    end
  end
  
  # This is to cleanup slicehost data that ends with '.'
  def data 
    attributes['data'].end_with?('.') && !self.ns? ? attributes['data'].sub(/\.$/,'') : attributes['data']
  end
end

error "Usage: slice2linode.rb domain.com. [domain2.com.] ..." if ARGV.empty? || ARGV.detect { |name| !name.end_with?('.') }

ARGV.each do |arg|
  # Slicehost requires . at the end of the domain name
  zone = Zone.find_by_name(arg)
  exit if zone.nil?
  if zone.nil? then
    $LOG.warn "No valid zone named #{arg} found"
    next
  end
  
  # Initiate Linode gem
  l = Linode.new(:api_key => LINODE_API_KEY)
  error "#{arg} already exists at linode please delete" if l.domain.list().find {|domain| domain.domain == zone.domain }
  
  # create linode domain - set it to INACTIVE by default
  puts "Creating #{zone.domain} @ linode.com"
  domain = l.domain.create(:Domain => zone.domain, :Type => 'Master', :SOA_Email => EMAIL_ADDRESS, :TTL_sec => zone.ttl, :status => 0)
  
  records = zone.records
  
  # Delete NS records as Linode's api creates them by default when create a domain
  records.delete_if { |record| record.ns? }
  
  records.each do |record|
    case record.kind
    when 'srv'
      puts "Creating SRV record"
      srvce, protocol = record.name.split(/\./)
      weight, port, target = record.data.split(' ')
      l.domain.resource.create(:DomainID => domain.domainid, :Type => 'SRV', :Name => srvce, :Priority => record.aux, :Target => target, 
                               :Priority => record.aux, :Weight => weight, :Port => port, :Protocol => protocol.sub('_',''), :TTL_sec => record.ttl)
    when 'mx'
      puts "Creating MX record"
      l.domain.resource.create(:DomainID => domain.domainid, :Type => 'MX', :Target => record.data, :Priority => record.aux, :TTL_sec => record.ttl)
    when 'txt', 'cname', 'a'
      puts "Creating #{record.record_type} record"
      name = record.a? && record.name == zone.origin ? '' : record.name
      l.domain.resource.create(:DomainID => domain.domainid, :Type => record.record_type, :Name => name, :Target => record.data, :TTL_sec => record.ttl)
    end
  end
  puts "Done importing #{zone.domain}"
end