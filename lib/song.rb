# class Song

#   attr_accessor :name, :album, :id

#   def initialize(name:, album:, id: nil)
#     @id = id
#     @name = name
#     @album = album
#   end

#   def self.drop_table
#     sql = <<-SQL
#       DROP TABLE IF EXISTS songs
#     SQL

#     DB[:conn].execute(sql)
#   end

#   def self.create_table
#     sql = <<-SQL
#       CREATE TABLE IF NOT EXISTS songs (
#         id INTEGER PRIMARY KEY,
#         name TEXT,
#         album TEXT
#       )
#     SQL

#     DB[:conn].execute(sql)
#   end

#   def save
#     sql = <<-SQL
#       INSERT INTO songs (name, album)
#       VALUES (?, ?)
#     SQL

#     # insert the song
#     DB[:conn].execute(sql, self.name, self.album)

#     # get the song ID from the database and save it to the Ruby instance
#     self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM songs")[0][0]

#     # return the Ruby instance
#     self
#   end

#   def self.create(name:, album:)
#     song = Song.new(name: name, album: album)
#     song.save
#   end

#   def self.new_from_db(row)
#     # self.new is an equivalent of Song.new
#     self.new(id: row[0], name: row[1], album: row[2])
#   end

#   def self.all
#     sql = <<-SQL
#     SELECT *
#     FROM songs
#     SQL

#     DB[:conn].execute(sql).map do |row|
#       self.new_from_db(row)
#     end
#   end

#   def self.find_by_name(name)
#     sql = <<-SQL
#       SELECT *
#       FROM songs
#       WHERE name = ?
#       LIMIT 1
#     SQL
#     # binding.pry
#     DB[:conn].execute(sql, name).map do |row|
#       self.new_from_db(row)
#     end.first
#   end

# end



# -------UPDATING RECORDS-----------------------#

class Song
  attr_accessor :name, :album
  attr_reader :id

  def initialize(id=nil, name, album)
    @id = id
    @name = name
    @album = album
  end

  # drop table
  def self.drop_table
    sql = "DROP TABLE songs"
    DB[:conn].execute(sql)
  end

  # create the songs table
  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS songs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        album TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  # insert the records into the table
  def save
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO songs (name, album)
      VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.album)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM songs")[0][0]
    end
  end

  def self.create(name:, album:)
    song = Song.new(name, album)
    # binding.pry
    song.save
    song
  end

  # retrieve a song by name
  def self.find_by_name(name)
    sql = "SELECT * FROM songs WHERE name = ?"
    # binding.pry
    result = DB[:conn].execute(sql, name)[0]
    Song.new(result[0], result[1], result[2])
  end

  def update
    sql = "UPDATE songs SET name = ?, album = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.album, self.id)
  end

  # prevent creation of duplicate records
  # create a find_or_create_by method

  def self.find_or_create_by(name:, album:)
    song = DB[:conn].execute("SELECT * FROM songs WHERE name = ? AND album = ?", name, album)
    if !song.empty?
      song_data = song[0]
      song = Song.new(song_data[0], song_data[1], song_data[2])
    else
      song = self.create(name: name, album: album)
    end
    song
  end

end
