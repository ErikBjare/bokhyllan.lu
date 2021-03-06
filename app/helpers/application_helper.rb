module ApplicationHelper
  def standard_form_for(name, *args, &block)
    options = args.extract_options!

    form_for(name, *(args << options.merge(builder: StandardForm, html: { class: 'form' })), &block)
  end

  def search_bar(value = params[:search])
    render('search', value: value)
  end

  def root?
    :root if current_page?(root_path) and params[:search].blank?
  end
end
