require 'formula'

class Rethinkdb < Formula
  homepage 'http://www.rethinkdb.com/'
  url 'https://github.com/rethinkdb/rethinkdb/archive/v1.3.1.tar.gz'
  sha1 '090b296ed2966de917d6c1d9283ec8fa059c24aa'

  env :userpaths

  depends_on 'less' => :node
  depends_on 'coffee-script' => :node
  depends_on LanguageModuleDependency.new :ruby, 'ruby_protobuf', 'protobuf/compiler/compiler'

  def install
    system "cd src; make FETCH_INTERNAL_TOOLS=1 DEBUG=0 BUILD_PORTABLE=1 STATIC=1 FORCEVERSION=1 RETHINKDB_VERSION=#{version} PREFIX=#{prefix} WEBRESDIR=#{share}/rethinkdb/web"
    bin.install 'build/release/rethinkdb'

    (share/'rethinkdb').mkpath
    share.install 'build/release/web' => 'rethinkdb'

    (etc/'rethinkdb').mkpath
    (etc/'rethinkdb/default.conf').write rethinkdb_conf unless File.exists? etc+'rethinkdb/default.conf'

    %w[run/rethinkdb/instances.d lib/rethinkdb/instances.d log/rethinkdb].each { |path| (var+path).mkpath }
  end

  def rethinkdb_conf; <<-EOS.undent
    # You may need to execute the following command:
    # => rethinkdb create --directory #{var}/lib/rethinkdb/instances.d/default;
    runuser=#{`whoami`.chomp}
    rungroup=#{`whoami`.chomp}
    directory=#{var}/lib/rethinkdb/instances.d/default
    pid-file=#{var}/run/rethinkdb/instances.d/default.pid
    driver-port=28015
    cluster-port=29015
    http-port=8080
    EOS
  end

  plist_options :manual => "rethinkdb --config #{HOMEBREW_PREFIX}/etc/rethinkdb/default.conf"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_prefix}/bin/rethinkdb</string>
        <string>--config</string>
        <string>#{etc}/rethinkdb/default.conf</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>KeepAlive</key>
      <false/>
      <key>UserName</key>
      <string>#{`whoami`.chomp}</string>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
      <key>StandardErrorPath</key>
      <string>#{var}/log/rethinkdb/default.log</string>
      <key>StandardOutPath</key>
      <string>#{var}/log/rethinkdb/default.log</string>
    </dict>
    </plist>
    EOS
  end
end
