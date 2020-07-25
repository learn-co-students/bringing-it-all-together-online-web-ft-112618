class Dog

  attr_accessor :id, :name, :breed
  #attr_reader :id

  def initialize(id: nil, name:, breed:) #cannot have id=nil bc then it wouldn't follow hash format
    @id = id
    @name = name
    @breed = breed
  end 
  
  def self.create_table #remember to include columns :)
    sql= <<-SQL
    CREATE TABLE dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
      )
    SQL
  
  DB[:conn].execute(sql) #connects to database
  end 
  
  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs
    SQL
    
    DB[:conn].execute(sql) 
  end 
  
  def save #instance method because you are saving a row
    sql = <<-SQL
      INSERT INTO dogs (name,breed)
      VALUES (?, ?)
    SQL
    
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() from dogs")[0][0] #This would return an array of arrays w/o the double 0's. [0] = [1]; [0][0] = 1
    self #returning the row 
  end 
  
  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)#this is a hash
    dog.save
    dog
  end   
  
  def self.new_from_db(row) #creates object from database
    id = row[0]#the
    name = row[1]#set-
    breed = row[2]#up
    self.new(id: id, name: name, breed: breed)#the creation!
  end 
    
  
  def self.find_by_id(id)
    sql = <<-SQL 
    SELECT *
    FROM dogs
    WHERE id = ?
    SQL
    
    DB[:conn].execute(sql, id).map do |row|
     self.new_from_db(row)
    end.first #returns first element of array
  end 
  
  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty? #if dog instance exists we can play around with dog_data but it will not be saved to the database (avoiding dups!!)
      dog_data = dog[0]
      dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else #if doesn't exist, create object!
      dog = self.create(name: name, breed: breed)
    end 
    dog # return the object you either selected or created!!
  end 
  
  def self.find_by_name(name)
    sql = <<-SQL 
    SELECT *
    FROM dogs
    WHERE name = ?
    SQL
    
    DB[:conn].execute(sql, name).map do |row|
     self.new_from_db(row)
    end.first
  end 
  
  def update
    sql = <<-SQL 
      UPDATE dogs SET name = ?, breed = ? WHERE id = ? 
      SQL
    #editing the row based off of id, the uniqie identifier.   
    DB[:conn].execute(sql, self.name, self.breed, self.id) #you have to execute the inputs you entered. 
  end 
    
  
end 
  