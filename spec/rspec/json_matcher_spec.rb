require "spec_helper"

describe RSpec::JsonMatcher do
  context "with invalid JSON" do
    it "does not match" do
      "".should_not be_json
    end
  end

  context "with invalid keys JSON" do
    it "does not match" do
      {
        "a" => nil
      }.to_json.should_not be_json(
        "b" => nil
      )
    end
  end

  context "with valid JSON" do
    it "matches with handy patterns" do
      [
        {
          "url" => "https://api.github.com/gists/17a07d0a27fd3f708f5f",
          "id" => "1",
          "description" => "description of gist",
          "public" => true,
          "user" => {
            "login" => "octocat",
            "id" => 1,
            "avatar_url" => "https://github.com/images/error/octocat_happy.gif",
            "gravatar_id" => "somehexcode",
            "url" => "https://api.github.com/users/octocat"
          },
          "files" => {
            "ring.erl" => {
              "size" => 932,
              "filename" => "ring.erl",
              "raw_url" => "https://gist.github.com/raw/365370/8c4d2d43d178df44f4c03a7f2ac0ff512853564e/ring.erl"
            }
          },
          "comments" => 0,
          "comments_url" => "https://api.github.com/gists/6fb6af8cb6e26dbbc327/comments/",
          "html_url" => "https://gist.github.com/1",
          "git_pull_url" => "git://gist.github.com/1.git",
          "git_push_url" => "git@gist.github.com:1.git",
          "created_at" => "2010-04-14T02:15:15Z"
        }
      ].to_json.should be_json([
        {
          "url"          => /^https:/,
          "id"           => /^\d+$/,
          "description"  => /gist/,
          "public"       => true,
          "user"         => Hash,
          "files"        => Hash,
          "comments"     => Fixnum,
          "comments_url" => /^https:/,
          "html_url"     => /^https:/,
          "git_pull_url" => /^git:/,
          "git_push_url" => /^git@/,
          "created_at"   => /^\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\dZ/,
        }
      ])
    end
  end
end
