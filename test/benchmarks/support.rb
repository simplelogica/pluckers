require 'ruby-prof'

module Benchmark
  module ActiveRecord

    def active_record_version
      ::ActiveRecord.respond_to?(:version) ? ::ActiveRecord.version : Gem::Version.new(::ActiveRecord::VERSION::STRING)
    end

    def run(label = nil, version: active_record_version, time:, disable_gc: true, warmup: 3, &block)
      #::ActiveRecord::Base.logger = Logger.new(STDOUT)

      profiling = false

      RubyProf.start if profiling

      Benchmark::Runner.run(label, version: version, time: time, disable_gc: disable_gc, warmup: warmup, &block)

      if profiling
        result = RubyProf.stop
        printer = RubyProf::GraphHtmlPrinter.new(result)
        printer.print(File.new("result-#{label.gsub('/', '-')}-#{version}.html", 'w'))
      end
    end

  end


  extend Benchmark::ActiveRecord
end

require 'benchmark/ips'
require 'json'

module Benchmark
  module Runner
    def self.run(label=nil, version:, time:, disable_gc:, warmup:, &block)
      unless block_given?
        raise ArgumentError.new, "You must pass block to run"
      end

      GC.disable if disable_gc

      ips_result = compute_ips(time, warmup, label, &block)
      objects_result = compute_objects(&block)

      print_output(ips_result, objects_result, label, version)
    end

    def self.compute_ips(time, warmup, label, &block)
      report = Benchmark.ips(time, warmup, true) do |x|
        x.report(label) { yield }
      end

      report.entries.first
    end

    def self.compute_objects(&block)
      if block_given?
        key =
          if RUBY_VERSION < '2.2'
            :total_allocated_object
          else
            :total_allocated_objects
          end

        before = GC.stat[key]
        yield
        after = GC.stat[key]
        after - before
      end
    end

    def self.print_output(ips_result, objects_result, label, version)
      output = {
        label: label,
        version: version,
        iterations_per_second: ips_result.ips,
        iterations_per_second_standard_deviation: ips_result.stddev_percentage,
        total_allocated_objects_per_iteration: objects_result
      }.to_json

      puts output
    end
  end
end

def all_method
  active_record_version = ActiveRecord.respond_to?(:version) ? ActiveRecord.version : Gem::Version.new(ActiveRecord::VERSION::STRING)
  active_record_version < Gem::Version.new("4.0") ? :scoped : :all
end
