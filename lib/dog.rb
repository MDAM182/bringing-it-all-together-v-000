class Dog
    attr_accessor :name, :breed, :id


    def initialize(name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE dogs(
          id INTEGER PRIMARY KEY,
          name TEXT,
          breed TEXT
        );
        SQL

        DB[:conn].execute(sql)
      end


    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs"
        DB[:conn].execute(sql)
    end


    def self.create(attributes)
        dog = Dog.new(attributes)
        dog.save
      end

    def self.find_by_id(id)
        sql = <<-SQL
          SELECT *
          FROM dogs
          WHERE id = ?
        SQL

        DB[:conn].execute(sql, id).map { |row| new_from_db(row)}.first
    end
     def self.find_by_name(name)
        sql = <<-SQL
         SELECT *
         FROM dogs
         WHERE name = ?
         LIMIT 1
        SQL

        DB[:conn].execute(sql, name).map { |row| new_from_db(row) }.first
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !dog.empty?
          dog_data = dog[0]
          dog = self.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
        else
          dog = self.create(name: name, breed: breed)
        end
        dog
      end

    def self.new_from_db(row)
        Dog.new({name: row[1], breed: row[2], id: row[0]})
    end



    def save
        sql = <<-SQL
        INSERT INTO dogs(name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self

    end

    def update
        sql = <<-SQL
          UPDATE dogs
          SET name = ?, breed = ?
          WHERE id = ?;
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end
