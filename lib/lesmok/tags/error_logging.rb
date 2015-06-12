module Lesmok
  module Tags

      module ErrorLogging
        def log_exception(err, context)
          template_name = context[@template_name]
          err.message << " (in template '#{template_name}')" rescue nil
          err.blame_file! "#{template_name}.liquid" rescue nil
          Lesmok.logger.error "[#{self.class}] Liquid error in '#{template_name}': #{err.to_s} \n - #{err.backtrace.first(15).join("\n - ")}"
        rescue => err
          Lesmok.logger.error "[#{self.class}] META ERROR: Liquid exception reporting failure: #{err.to_s} \n - #{err.backtrace.first(15).join("\n - ")}"
        ensure
          raise err if Lesmok.config.debugging?
          ""
        end

        def with_exception_logging(context)
          begin
            yield
          rescue => err
            log_exception(err, context)
          end
        end
      end

  end
end