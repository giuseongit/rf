require "./spec_helper"

describe "Rf.config" do
  it "Config serialization" do
    cfg = uninitialized Rf::Config
    cfg.repositories_dir = "/example"
    cfg.entries_shown = 2
    cfg.enabled_vsc = Rf::SupportedVSC::Git | Rf::SupportedVSC::Svn
    cfg.subrepository_depth = 1

    cfg.to_yaml.should eq "---
repositories_dir: /example
entries_shown: 2
enabled_vsc: git|svn
subrepository_depth: 1\n"

    cfg.enabled_vsc = Rf::SupportedVSC::Git

    cfg.to_yaml.should eq "---
repositories_dir: /example
entries_shown: 2
enabled_vsc: git
subrepository_depth: 1\n"
  end

  it "Config deserialization" do
    cfg_yaml = "---
    repositories_dir: /test
    entries_shown: 3
    enabled_vsc: git|svn
    subrepository_depth: 4\n"

    cfg = Rf::Config.from_yaml(cfg_yaml)
    cfg.repositories_dir.should eq "/test"
    cfg.entries_shown.should eq 3
    cfg.enabled_vsc.should eq Rf::SupportedVSC::Git | Rf::SupportedVSC::Svn
    cfg.subrepository_depth.should eq 4

    cfg_yaml = "---
repositories_dir: /test
entries_shown: 3
enabled_vsc: svn
subrepository_depth: 4\n"

    cfg = Rf::Config.from_yaml(cfg_yaml)
    cfg.repositories_dir.should eq "/test"
    cfg.entries_shown.should eq 3
    cfg.enabled_vsc.should eq Rf::SupportedVSC::Svn
    cfg.subrepository_depth.should eq 4
  end
end
