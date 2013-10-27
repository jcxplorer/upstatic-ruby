require "cases/helper"

class TestInvalidations < Upstatic::TestCase

  def self.config
    return @config if @config
    @config = Upstatic::Configuration.new
    @config.distribution_id "EX7C5EKLRKVC7"
    @config
  end

  def config
    self.class.config
  end

  def last_invalidation_id
    AWS::CloudFront.new.client.list_invalidations(
      :distribution_id => config.distribution_id,
      :max_items => 1
    )[:items][0][:id]
  end

  def last_invalidation
    AWS::CloudFront.new.client.get_invalidation(
      :distribution_id => config.distribution_id,
      :id => last_invalidation_id
    )
  end

  def last_invalidated_items
    last_invalidation[:invalidation_batch][:paths][:items]
  end

  def test_creates_invalidation_rules
    deploy :invalidations, config

    paths = last_invalidated_items

    assert_equal 7, paths.count

    assert_includes paths, "/"
    assert_includes paths, "/index.html"
    assert_includes paths, "/scripts.js"
    assert_includes paths, "/styles.css"
    assert_includes paths, "/folder"
    assert_includes paths, "/folder/"
    assert_includes paths, "/folder/index.html"

    changed_file = File.join(TEST_UPLOAD_DIR, "scripts.js")
    write_file(changed_file, "UPSTATIC_CHANGED")

    new_config = config.dup
    new_config.cache_control ".css", "private, max-age=0"

    deploy :invalidations, new_config, true

    paths = last_invalidated_items

    assert_equal 2, paths.count
    assert_includes paths, "/scripts.js"
    assert_includes paths, "/styles.css"
  end
  
end
