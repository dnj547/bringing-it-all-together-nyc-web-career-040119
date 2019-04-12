class Dog

  attr_accessor :name, :breed, :id

  def initialize(dog)
    @name = dog[:name]
    @breed = dog[:breed]
    @id = nil
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE dogs
    SQL
  DB[:conn].execute(sql)
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    if !!self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

  def self.new_from_db(row)
    dog = {}
    dog[:name] = row[1]
    dog[:breed] = row[2]
    new_dog = Dog.new(dog)
    new_dog.id = row[0]
    new_dog
  end

  def self.create(dog={})
    new_dog = Dog.new(dog)
    new_dog.save
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    row = DB[:conn].execute(sql, id).first
    self.new_from_db(row)
  end

  def self.find_or_create_by(info)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    row = DB[:conn].execute(sql, info[:name], info[:breed]).first
    if row.nil?
      new_dog = Dog.new(info)
      new_dog.save
    else
      self.new_from_db(row)
    end
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    row = DB[:conn].execute(sql, name).first
    self.new_from_db(row)
  end

end
