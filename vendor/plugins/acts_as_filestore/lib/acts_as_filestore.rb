# ActsAsFilestore
module ActsAsFilestore
  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
		# Specify this +acts_as+ extension if you want model attributes to be stored in local file instead of database.
		# This extension is specifically useful for large BLOBs
		#
		#	Usage:
		#
		#   class Category < ActiveRecord::Base
		#     acts_as_filestore :large_binary_column, :dir => "Data"
		#   end
		#
		# If a <tt>:dir</tt> option is provided it will be used as
		# store directory for attribute values. Otherwise Rails_ROOT + "log" is used.
    def acts_as_filestore(*args)
			#send :include, ActiveSupport::Memoizable
      send :extend, ActiveSupport::Memoizable

			cattr_accessor :acts_as_filestore_config
			after_save :acts_as_filestore_save
			before_destroy :acts_as_filestore_destroy

			options = args.extract_options!
			raise "acts_as_filestore - require attribute names and options as input params" if args.empty?
			
			configuration = { :dir => RAILS_ROOT + "/log/", :attributes => args}
			configuration.update(options) if options.is_a?(Hash)
			self.acts_as_filestore_config = configuration

			send :include, InstanceMethods

			# create setter & getter foreach attribute, use memorize to limit io
			args.each do |arg|
				src = <<-END_SRC
					def #{arg.to_s}=(value)
						#{arg.to_s}_will_change!
						@#{arg.to_s}=value
					end

					def #{arg.to_s}
						@#{arg.to_s} = File.new(File.join(act_as_filestore_dir, "#{arg.to_s}.store")).read rescue nil
					end
					memoize :#{arg.to_s}
				END_SRC
				class_eval src, __FILE__, __LINE__
			end

    end
  end

  module InstanceMethods
		protected

			# get instance store directory
			def act_as_filestore_dir
				File.join(self.class.acts_as_filestore_config[:dir], self.class.name.underscore, self.id.to_s)
			end

			# call assign again - this time with id available it will store attribute value in a file
			def acts_as_filestore_save
				FileUtils::mkdir_p(act_as_filestore_dir)
				self.class.acts_as_filestore_config[:attributes].each do |arg|
					# store only changed values
					if send(:"#{arg}_changed?")
						File.open(File.join(act_as_filestore_dir, "#{arg.to_s}.store"), File::CREAT|File::TRUNC|File::RDWR) { |f| f.write(instance_variable_get(:"@#{arg}")) }
					end
				end
			end

			# remove whole instance directory
			def acts_as_filestore_destroy
				FileUtils::remove_dir(act_as_filestore_dir, true)
			end

  end
end