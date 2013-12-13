module ItemsHelper
  def item_courses(item)
    item.courses.map { |course| "#{course.code} - #{course.name}" }.join('<br>').html_safe
  end

  def item_tags(item)
    item.tags.map { |tag| tag.prepend('#') }.join(' ')
  end

  def item_programs(item)
    item.courses.map(&:programs).flatten.uniq.sort.to_sentence
  end
end
