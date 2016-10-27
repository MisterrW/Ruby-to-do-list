require 'json'

module NewList
  
  def NewList.chooser
    puts "Do you want to LOAD a list or make a NEW list?"
    choice = gets.chomp.upcase
    case choice
    when "LOAD"
      NewList.load_list
    when "NEW"
      NewList.make_new_list
    else
      puts "Sorry, please type LOAD or NEW"
      NewList.chooser
    end
  end

  def NewList.load_list
    #Extracts the JSON data from the file
    data_from_file = File.read("tdl-store.json")
    #Creates hash from JSON data
    hash_from_file = JSON.parse(data_from_file)
    #Rest of function assigns variables for the list object from the hash file, and then creates the list as an instance of the TodoList class, using the values loaded from the JSON
    list_name = hash_from_file["list_name"]
    owner = hash_from_file["owner"]
    items = hash_from_file["items"]
    list = TodoList.new(list_name, owner, items)
    #Drops you into the chooser function of the newly created list instance
    list.chooser
  end

  #Alternative function for when user wants to create a new list instead of loading from JSON
  def NewList.make_new_list
    puts "enter list name"
    list_name = gets.chomp
    puts "enter your name"
    owner = gets.chomp
    list = TodoList.new(list_name, owner)
    list.chooser
  end
end

class TodoList
  #note conditional assignment of placeholder hash to items variable (overridden if new items hash supplied)
  def initialize(list_name, owner, items= {"haircut" => {description: "get it cut", time_added: "today", status: "Incomplete"}, "fishing" => {description: "catch fish", time_added: "yesterday", status: "Incomplete"} })
    @name = list_name
    @owner = owner
    @items = items
  end

  #attr_accessor(@items)

  def chooser
    puts "NEW, LIST, LEAVE, UPDATE, DELETE, SAVE ?"
    choice = gets.chomp.upcase
    case choice
    when "NEW"
      new_task
    when "LIST"
      read_list
    when "UPDATE"
      mark_completed
    when "DELETE"
      delete_task
    when "SAVE"
      save_list
    when "LEAVE"
      puts "bye"
    else
      puts "Whoops, didn't understand you! Try again!"
      chooser
    end
  end

  def new_task
    puts "What's the task?"
    item = gets.chomp
    puts "enter a description of the task (optional, just press enter if you want)"
    description = gets.chomp
    if description == ""
      description = item
    end
    time = Time.now
    status = "Incomplete"
    #Creates a new key in the @items hash, whose value is itself a hash containing the keys description, time_added and status (these keys are symbols, even though when declaring them in this syntax don't need to prepend the :)
    @items[item] = {description: description, time_added: time, status: status}
    puts "'#{item}' added"
    chooser
  end

  def delete_task
    puts "These are current tasks"
    #Syntax specifies key (a is key, b is value) so it prints out a list of keys in @items. Remember how the each method works - it's an iterator containing a yield statement that executes the provided block on each item in the hash or array.
    @items.each do |a, b|
      puts "#{a}"
    end
    puts ""
  
    puts "Type the name of the task you wish to delete, then press enter"
    to_delete = gets.chomp
    #Again, piped values represent key and value. Note that the characters used are arbitrary - x and y here, a and b above - they are just placeholders to tell the block what to do.
    @items.each do |x, y|
      if x == to_delete
        @items.delete(x)
        puts "'#{to_delete}' deleted"
      end
    end
    chooser
  end

  def mark_completed
    puts "these are current tasks marked incomplete:"
    #This block goes a bit deeper into the hash nesting - again, a is key and b is value in @items, but then :status is a key in each b (which is a hash in itself). The .each method iterates over each item in @items, and if the value for the :status key in the associated hash is "Incomplete", it lists the key in @items. 
    @items.each do |a, b|
      if b[:status] == "Incomplete"
      puts "#{a}"
      end
    end
    puts "type the name of the task you want to mark as completed, then press enter"
    to_complete = gets.chomp
    #More or less the same as just above
    @items.each do |a, b|
      if a == to_complete
        b[:status] = "Completed"
        puts "'#{to_complete}' completed."
      end
    end
    chooser
  end

  def read_list
    #unless statement checks that the to-do list hash @items is actually populated - if it's empty, it says so (else statement)
    unless @items == {}
      #This is another level deeper into the hash nesting. First bit, as before, just iterates over the key-value pairs in the @items hash, putting the keys.
      @items.each do |a, b|
        puts "#{a}"
        #This bit then iterates over the key-value pairs in each value in @items (remember, these are hashes themselves - check the JSON!). b = a value in @items, and therefore a hash, c = a key in a hash b, d = the corresponding value to each c. The keys in each hash b are :description, :status and :time, and the values of each of these keys, for each b hash, are what gets puts. The "-" just makes the list look nicer in the terminal.
        b.each do |c, d|
          puts "- #{d}"
        end
        puts ""
      end
    else
      puts "No to-do items found"
    end
    chooser
  end

  def save_list
    hash_to_save = {owner: @owner, list_name: @name, items: @items}
    #More JSON magic. Learn about this!
    File.open("tdl-store.json","w") do |x|
      x.write(hash_to_save.to_json)
      puts "List saved."
    end
  end

end

NewList.chooser