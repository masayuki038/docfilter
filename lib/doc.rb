module Doc
  def self.get_words(doc)
    dict = {}
    doc.split(/\W+/).each do |w|
      dict[w.downcase] = 1 if(w.size > 2 && w.size < 20)
    end
    dict
  end

  class Classifier
    def initialize(filename = nil)
      @fc = {} # counts of feature/category combinations
      @cc = {} # counts of documents in each category
    end

    def inc_feature(feat, category)
      @fc[feat] ||= {}
      @fc[feat][category] ||= 0
      @fc[feat][category] += 1
#puts "inc_feature"
#p @fc
    end

    def get_feature_count(feat, category)
      (@fc[feat] && @fc[feat][category])? @fc[feat][category] : 0
    end

    def inc_category(category)
      @cc[category] ||= 0
      @cc[category] += 1
    end

    def get_category_count(category)
      (@cc[category])? @cc[category] : 0
    end

    def categories()
      @cc.keys
    end

    def total_count()
      @cc.values.inject(0) do |ret, c|
        ret + c
      end
    end

    def train(item,category)
 #     p Doc.get_words(item)
      Doc.get_words(item).keys.each do |f|
        inc_feature(f, category)
      end
      inc_category(category)
      puts "train. #{category}: #{get_category_count(category)}"
    end

    def fprob(feat, category)
      cat_count = get_category_count(category)
      return 0 if cat_count == 0
      puts "feat: #{feat}, get_feature_count: #{get_feature_count(feat, category).prec_f}"
      get_feature_count(feat, category).prec_f / cat_count
    end

    def weighted_prob(feat, category, weight = 1.0, ap = 0.5)
      basicprob = fprob(feat, category)
      totals = get_category_count(category)
      puts "#{category}: #{totals}, basicprob: #{basicprob}"
      ((weight * ap) + (totals * basicprob)).prec_f / (weight + totals)
    end
  end

  class NaiveBayes < Classifier
    def initialize
      super
      @thresholds = {}
    end

    def doc_prob(doc, category)
      p = 1
      Doc.get_words(doc).each do |w, count|
        puts "w: #{w}"
        p *= weighted_prob(w, category)
      end
      p
    end

    def prob(item, category)
      cat_prob = get_category_count(category).prec_f / total_count
      doc_prob = doc_prob(item, category)
      cat_prob * doc_prob
    end

    def set_threshold(category, t)
      @thresholds[category] = t
    end

    def get_threshold(category)
      (@thresholds[category])? @thresholds[category] : 1.0
    end

    def classify(item)
      probs = {}
      best = nil
      max = 0.0
      categories.each do |c|
        probs[c] = prob(item, c)
        if probs[c] > max
          max = probs[c]
          best = c
        end
      end

      probs.each do |c, p|
        next if c == best
        return :unknown if p * get_threshold(best) > probs[best]
      end
      best
    end
  end

end
