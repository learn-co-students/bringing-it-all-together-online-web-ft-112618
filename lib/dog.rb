require "pry"

class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name: nil, breed: nil, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs (
        id INTETER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL

    DB[:conn].execute(sql)
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save

    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.create(name:, breed:)                #(hash)
    new_dog = Dog.new(name:name, breed:breed)   # make the name and breed optional in initialize

                                                # hash.each do |method, value|
                                                #   new_dog.send(("#{method}="), value)
                                                # end
    new_dog.save
    new_dog
  end

  def self.new_from_db(row)
    new_dog = Dog.new(name: row[1], breed: row[2], id: row[0])
  end

  def self.find_by_id(dog_id)

    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?

    SQL

    DB[:conn].execute(sql, dog_id).map do |row|
      #self.new(name:row[1], breed:row[2], id:row[0])
      self.new_from_db(row)
    end.first

  end

  def self.find_by_name(dog_name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL

    DB[:conn].execute(sql, dog_name).map do |row|
      self.new_from_db(row)
    end.first

  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ? AND breed = ?
    SQL
    dog_row = DB[:conn].execute(sql, name, breed)

    if !dog_row.empty? # if the condition is true, new_dog is not empty string.
      # need to instanctiate the instance, but not save it.
      dog_data = dog_row[0]
      new_dog = Dog.new(name: dog_data[1], breed: dog_data[2], id: dog_data[0])
    else # dog_row has no data , need to instanctiate and save to database.
      new_dog = self.create(name: name, breed: breed)
    end
    new_dog
  end



end #end of class

# sql = <<-SQL
#
#     SQL
