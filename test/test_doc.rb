#
# To change this template, choose Tools | Templates
# and open the template in the editor.


$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'doc'

class DocTest < Test::Unit::TestCase
  def test_get_words
    dict = Doc.get_words(" foo  bar hoge  hogehoge bar ")
    assert_equal(4, dict.size)
    assert_equal(1, dict["foo"])
    assert_equal(1, dict["bar"])
    assert_equal(1, dict["hoge"])
    assert_equal(1, dict["hogehoge"])

    dict = Doc.get_words('foo')
    assert_equal(1, dict["foo"])
  end

  def test_feature_count
    cl = Doc::Classifier.new
    cl.inc_feature('foo', 'bar')
    cl.inc_feature('foo', 'bar')
    cl.inc_feature('bar', 'hoge')

    assert_equal(2, cl.get_feature_count('foo', 'bar'))
    assert_equal(1, cl.get_feature_count('bar','hoge'))
    assert_equal(0, cl.get_feature_count('foo','hoge'))
    assert_equal(0, cl.get_feature_count('hoge', 'hogehoge'))
  end

  def test_category_count
    cl = Doc::Classifier.new
    cl.inc_category('foo')
    cl.inc_category('foo')
    cl.inc_category('bar')

    assert_equal(2, cl.get_category_count('foo'))
    assert_equal(1, cl.get_category_count('bar'))
    assert_equal(0,  cl.get_category_count('hogehoge'))

    assert_equal(['foo', 'bar'], cl.categories)
    assert_equal(3, cl.total_count)
  end

  def test_train
    cl = train
    assert_equal(1, cl.get_feature_count('bar', :good))
    assert_equal(2, cl.get_feature_count('foo', :good))
    assert_equal(1, cl.get_feature_count('hoge', :good))
    assert_equal(0, cl.get_feature_count('hogehoge', :good))
  end

  def test_fprob
    cl = train
    #puts cl.fprob('foo', :good)
    assert_equal(1, cl.fprob('foo', :good))
    assert_equal(0.5, cl.fprob('bar', :good))
    assert_equal(0, cl.fprob('hogehoge', :good))
  end

  def test_weighted_prob
    cl = train
    assert_equal(0.75, cl.weighted_prob('foo', :good, 2.0, 0.5))
    assert_equal(0.5, cl.weighted_prob('bar', :good))
    assert_equal(0.25, cl.weighted_prob('hogehoge', :good, 2.0, 0.5))
  end

  def test_doc_prob
    puts "test_doc_prob"
    n = Doc::NaiveBayes.new
    n.train('foo bar hoge bar', :good)
    assert_equal(0.75*0.75, n.doc_prob('foo bar', :good))
  end

  def test_prob
    puts "test_prob"
    cl = train("Doc::NaiveBayes")
    assert_equal((5.prec_f/6 * 0.5 * 0.5), cl.prob("foo bar", :good))
  end

  def test_classify
    puts "test_classify"
    cl = train("Doc::NaiveBayes")
    assert_equal(:good, cl.classify("hoge"))
    assert_equal(:good, cl.classify("foo"))
    assert_equal(:bad, cl.classify("hogehoge"))
  end

  def train(clazz = "Doc::Classifier")
    cl = eval("#{clazz}.new")
    cl.train('foo bar hoge bar', :good)
    cl.train('foo', :good)
    cl.train('foo hogehoge', :bad)
    cl.train('bar', :bad)
    cl
  end
end
