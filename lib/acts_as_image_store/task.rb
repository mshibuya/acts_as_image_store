require 'rails/generators'

module ActsAsImageStore
  class Task
    class << self
      def copy_asset_files
        puts "Copying asset files..."
        origin = File.join(gem_path, 'public')
        destination = Rails.root.join('public')
        puts copy_files(%w( javascripts ), origin, destination)
      end

      def copy_view_files
        puts "Copying view files..."
        origin = File.join(gem_path, 'app', 'views')
        destination = Rails.root.join('app', 'views')
        puts copy_files(%w( layouts ), origin, destination)
      end

      private

      def copy_files(directories, origin, destination)
        directories.each do |directory|
          Dir[File.join(origin, directory, '**/*')].each do |file|
            relative  = file.gsub(/^#{origin}\//, '')
            dest_file = File.join(destination, relative)
            dest_dir  = File.dirname(dest_file)

            if !File.exist?(dest_dir)
              FileUtils.mkdir_p(dest_dir)
            end

            copier.copy_file(file, dest_file) unless File.directory?(file)
          end
        end
      end

      def gem_path
        File.expand_path('../..', File.dirname(__FILE__))
      end

      def copier
        unless @copier
          Rails::Generators::Base.source_root(gem_path)
          @copier = Rails::Generators::Base.new
        end
        @copier
      end
    end
  end
end

