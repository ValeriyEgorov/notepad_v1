# encoding: UTF-8
if Gem.win_platform?
  Encoding.default_external = Encoding.find(Encoding.locale_charmap)
  Encoding.default_internal = __ENCODING__

  [STDIN, STDOUT].each do |io|
    io.set_encoding(Encoding.default_external, Encoding.default_internal)
  end
end

require_relative 'lib/post'
require_relative 'lib/link'
require_relative 'lib/memo'
require_relative 'lib/task'

require 'optparse'

# Все наши опции будут записаны сюда
options = {}

# Заведем нужные нам опции
OptionParser.new do |opt|
  # Этот текст будет выводиться, когда программа запущена с опцией -h
  opt.banner = 'Usage: read.rb [options]'

  # Вывод в случае, если запросили help
  opt.on('-h', 'Prints this help') do
    puts opt
    exit
  end

  # Опция --type будет передавать тип поста, который мы хотим считать
  opt.on('--type POST_TYPE', 'какой тип постов показывать ' \
         '(по умолчанию любой)') { |o| options[:type] = o }

  # Опция --id передает номер записи в базе данных (идентификатор)
  opt.on('--id POST_ID', 'если задан id — показываем подробно ' \
         ' только этот пост') { |o| options[:id] = o }

  # Опция --limit передает, сколько записей мы хотим прочитать из базы
  opt.on('--limit NUMBER', 'сколько последних постов показать ' \
         '(по умолчанию все)') { |o| options[:limit] = o }

  # В конце у только что созданного объекта класс OptionParser вызываем
  # метод parse, чтобы он заполнил наш хэш options в соответствии с правилами.
end.parse!

result = if options[:id].nil?
           Post.find_all(options[:limit], options[:type])
         else
           Post.find_by_id(options[:id])
         end
if result.is_a?(Post)
  puts "Запись #{result.class.name}, id = #{options[:id]}"
  result.to_string.each do |line|
    puts line
  end
else
  print "|id                   "
  print "|@type                "
  print "|@created_at          "
  print "|@text                "
  print "|@url                 "
  print "|@due_date            "
  result.each do |row|
    puts
    row.each do |element|
      print_element = "|#{element.to_s.delete("\\n\\r")[0..17]}"
      print_element << ' ' * (22 - print_element.size)
      print print_element
    end
  end
end
