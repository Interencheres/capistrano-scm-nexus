load File.expand_path('../tasks/nexus.rake', __FILE__)
require 'capistrano/scm'
require 'net/http'

class NexusTools

  def initialize
    @endpoint = fetch(:nexus_endpoint)
    @artifact_group = fetch(:nexus_artifact_group)
    @artifact_name = fetch(:nexus_artifact_name)
    @artifact_version = fetch(:nexus_artifact_version).upcase
    @artifact_extension = fetch(:nexus_artifact_extension)
    @artifact_repository = fetch(:nexus_artifact_repository)
  end

  def get_artifact_uri
    uri = URI("#{@endpoint}/service/local/artifact/maven/redirect?g=#{@artifact_group}&a=#{@artifact_name}&e=#{@artifact_extension}&v=#{@artifact_version}&r=#{@artifact_repository}")
    uri
  end

  def get_artifact_name
    @artifact_name
  end

  def get_revision
    @artifact_version
  end

  def get_artifact_archive_name
    artifact_archive_name = "#{@artifact_name}_#{@artifact_version}.#{@artifact_extension}"
    artifact_archive_name
  end

end

class Capistrano::Nexus < Capistrano::SCM
  module DefaultStrategy
    def check
      begin
        nexus = NexusTools.new
        uri = nexus.get_artifact_uri
        res = Net::HTTP.get_response(uri)
        case res
          when Net::HTTPSuccess then
            true
          when Net::HTTPRedirection then
            location = res['location']
            # follow 10 redirections max
            fetch(location, 10)
            true
          else
            false
        end
        set :artifact_url, uri.to_s
        set :artifact_version, nexus.get_revision
        set :artifact_archive_name, nexus.get_artifact_archive_name
      rescue StandardError => e
        puts "ERROR: #{e}, backtrace: \n#{e.backtrace}"
        false
      end
    end

    def download
      context.execute :wget, '--progress=bar:force', '--no-check-certificate -O', "#{fetch(:artifact_archive_name)}", "'#{fetch(:artifact_url)}'"
    end

    def release
      context.execute :tar, '-xzf', "#{fetch(:artifact_archive_name)}", '-C', fetch(:release_path)
    end

    def fetch_revision
      fetch(:artifact_version)
    end

  end
end
