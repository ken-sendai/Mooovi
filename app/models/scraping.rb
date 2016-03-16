class Scraping 
  def self.movie_urls
    agent = Mechanize.new
    links = []

    #パスの部分を変数で定義
    next_url = "/now/"

    while true do

      page = agent.get("http://eiga.com" + next_url)
      elements = page.search('.m_unit h3 a')
      elements.each do |ele|
        links << ele.get_attribute('href')
      end

      #「次へ」を表すタグを取得
      next_link = page.at('.next_page')
      #そのタグからhref属性の値を取得
      next_url = next_link.get_attribute("href")

      #next_urlがなかったらwhile文を抜ける
      break unless next_url

    end

    links.each do |link|
      get_product('http://eiga.com' + link)
    end
  end

  def self.get_product(link)
    agent = Mechanize.new
    page = agent.get(link)
    title = page.at('.moveInfoBox h1').inner_text if page.at('.moveInfoBox h1')
    image_url = page.at('.pictBox img')[:src] if page.at('.pictBox img')
    director = page.at('.f span').inner_text if page.at('.f span')
    detail = page.at('.outline p').inner_text if page.at('.outline p')
    open_date = page.at('.opn_date strong').inner_text if page.at('.opn_date strong')

    product = Product.where(title: title, image_url: image_url).first_or_initialize
    product.director = director
    product.detail = detail
    product.open_date = open_date
    product.save
  end
end
