require 'pry'

class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil, name:, breed:)
    @name = name
    @breed = breed
    @id = id
  end

  ##########################
  #### Instance Methods ####
  ##########################

  def save
    DB[:conn].execute(<<~SQL, self.name, self.breed)
    INSERT INTO dogs (name, breed)
    VALUES (?, ?)
    SQL
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def update
    DB[:conn].execute(<<~SQL, self.name, self.breed, self.id)
    UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    self
  end

  ##########################
  ##### Class  Methods #####
  ##########################

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if dog.empty?
      Dog.create(name: name, breed: breed)
    else
      dog_data = dog[0]
      Dog.new_from_db(dog_data)
    end
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
  end

  def self.find_by_id(id)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)[0]
    Dog.new_from_db(row)
  end

  def self.find_by_name(name)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0]
    Dog.new_from_db(row)
  end

  def self.new_from_db(row)
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.create_table
    DB[:conn].execute(<<~SQL)
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    );
    SQL
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

end
