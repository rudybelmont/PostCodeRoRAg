namespace :import_data do
  require 'csv'
  
  def execution_time(start, finish)
    diff = finish - start
    [diff.to_i / 3600, diff.to_i / 60 % 60, diff.to_i % 60].map { |t| t.to_s.rjust(2, '0') }.join(':')
  end

  def db_conn
    ActiveRecord::Base.connection
  end
  
  # usage: rake import_data:postcode_csv["/path/to/file"]
  task :postcode_csv, [:file_path] => :environment do |_t, args|
    start = Time.now

    import_postcode_csv(args[:file_path])

    exec_time = execution_time(start, Time.now)
    puts "execution time: #{exec_time}"
  end

  def import_postcode_csv(file_path)
    line_number = 0
    parsed_count = 0
    batch_state = []
    batch_postcode = []
    batch_suburb = []
    state_list = []
    postcode_list = []
    field_timestamp = DateTime.now.to_s(:db)

    CSV.foreach(file_path, col_sep: ',') do |row|
      line_number += 1
      next if line_number == 1

      state, suburb, postcode, postcode_desc = row.each { |el| el.try(:strip!) }
      unless state_list.include? state
        state_list.push state
        batch_state.push "(#{state_list.length}, '#{state}', '#{field_timestamp}', '#{field_timestamp}')"
      end

      state_id = state_list.index(state) + 1

      unless postcode_list.include? postcode
        postcode_list.push postcode
        batch_postcode.push "(#{postcode_list.length}, '#{postcode}', '#{postcode_desc}', "\
                            "'#{state_id}', '#{field_timestamp}', '#{field_timestamp}')"
      end

      postcode_id = postcode_list.index(postcode) + 1

      batch_suburb.push "('#{db_conn.quote_string(suburb)}', '#{postcode_id}', '#{field_timestamp}', "\
                        "'#{field_timestamp}')"

      parsed_count += 1
    end

    unless batch_state.empty?
      print "inserting #{batch_state.length} batch\n"
      mass_insert_state_csv batch_state
    end

    unless batch_postcode.empty?
      print "inserting #{batch_postcode.length} batch\n"
      mass_insert_postcode_csv batch_postcode
    end

    unless batch_suburb.empty?
      print "inserting #{batch_suburb.length} batch\n"
      mass_insert_suburb_csv batch_suburb
    end

    print "total parsed #{parsed_count}\n"
  end

  def mass_insert_state_csv(batch)
    return if batch.empty?

    begin
      sql = "INSERT INTO states (id, name, created_at, updated_at) VALUES #{batch.join(', ')};"\
            "SELECT setval('states_id_seq', max(id)) FROM states;"
      db_conn.execute sql
      return true
    rescue => e
      print e.to_s[0, 350] + "\n"
      return false
    end
  end

  def mass_insert_postcode_csv(batch)
    return if batch.empty?

    begin
      sql = 'INSERT INTO postcodes (id, code, description, state_id, created_at, updated_at) '\
            "VALUES #{batch.join(', ')};"\
            "SELECT setval('postcodes_id_seq', max(id)) FROM postcodes;"
      db_conn.execute sql
      return true
    rescue => e
      print e.to_s[0, 350] + "\n"
      return false
    end
  end

  def mass_insert_suburb_csv(batch)
    return if batch.empty?

    begin
      sql = "INSERT INTO suburbs (name, postcode_id, created_at, updated_at) VALUES #{batch.join(', ')}"
      db_conn.execute sql
      return true
    rescue => e
      print e.to_s[0, 350] + "\n"
      return false
    end
  end

  # usage rake import_data:geojson["/path/to/file"]
  task :geojson, [:file_path] => :environment do |_t, args|
    start = Time.now

    import_geojson(args[:file_path])

    exe_time = execution_time(start, Time.now)
    print "execution time : #{exe_time}\n"
  end

  def import_geojson(file_path)
    line_number = 0
    error_count = 0
    parsed_count = 0
    File.open(file_path, 'r').each_line do |line|
      line_number += 1
      begin
        line_clean = line.strip.chomp(',')
        parsed = JSON.parse line_clean
        postcode = parsed['properties']['POA_2006']
        parsed_count += 1

        update_boundary(postcode, line_clean)
      rescue JSON::ParserError => e
        if line.length > 100 # not line we looking for
          print 'error readline ' + line[0, 80] + "\n"
          print e.to_s[0, 300] + "\n"
        end
        error_count += 1
        break if error_count > 10
      rescue => e
        print e.to_s[0, 300] + "\n"
        break
      end
    end

    print "total parsed #{parsed_count}\n".ljust(30)
  end

  def update_boundary(code, data)
    return if code.nil?

    postcodes = Postcode.where('code = ?', code)

    return if postcodes.empty?

    print "Updating Postcode #{code} boundary".ljust(30)
    postcodes[0].update(boundary: data.gsub(/"/,'"'))
    print "\r"
  end
end
