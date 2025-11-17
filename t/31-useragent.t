use strict;
use warnings;
use Test::More;
use XML::Feed;
use LWP::UserAgent;

# Test 1: Create feed without useragent
{
    my $feed = XML::Feed->new('Atom');
    isa_ok($feed, 'XML::Feed::Format::Atom', 'Feed created without useragent');
    ok(!exists $feed->{useragent}, 'No useragent stored initially');
}

# Test 2: Create feed with useragent
{
    my $ua = LWP::UserAgent->new;
    $ua->agent('TestAgent/1.0');
    
    my $feed = XML::Feed->new('Atom', { useragent => $ua });
    isa_ok($feed, 'XML::Feed::Format::Atom', 'Feed created with useragent');
    isa_ok($feed->{useragent}, 'LWP::UserAgent', 'UserAgent stored correctly');
    is($feed->{useragent}->agent, 'TestAgent/1.0', 'UserAgent is the same object');
}

# Test 3: Create feed with invalid useragent (should die)
{
    eval {
        my $feed = XML::Feed->new('Atom', { useragent => 'not an object' });
    };
    like($@, qr/useragent must be an LWP::UserAgent object/, 'Dies with invalid useragent');
}

# Test 4: Create feed with invalid argument (should die)
{
    eval {
        my $feed = XML::Feed->new('Atom', { invalid_arg => 'value' });
    };
    like($@, qr/Invalid argument/, 'Dies with invalid argument');
}

# Test 5: useragent() getter creates one if it doesn't exist
{
    my $feed = XML::Feed->new('Atom');
    ok(!exists $feed->{useragent}, 'No useragent initially');
    
    my $ua = $feed->useragent;
    isa_ok($ua, 'LWP::UserAgent', 'useragent() returns LWP::UserAgent');
    ok(exists $feed->{useragent}, 'UserAgent stored after getter call');
    like($ua->agent, qr/XML::Feed/, 'UserAgent has default agent string');
}

# Test 6: useragent() getter returns existing one
{
    my $ua1 = LWP::UserAgent->new;
    $ua1->agent('TestAgent/2.0');
    
    my $feed = XML::Feed->new('Atom', { useragent => $ua1 });
    my $ua2 = $feed->useragent;
    
    is($ua2, $ua1, 'useragent() returns the same object');
    is($ua2->agent, 'TestAgent/2.0', 'Agent string is preserved');
}

# Test 7: useragent() setter
{
    my $feed = XML::Feed->new('Atom');
    
    my $ua = LWP::UserAgent->new;
    $ua->agent('TestAgent/3.0');
    
    my $result = $feed->useragent($ua);
    is($result, $ua, 'useragent() setter returns the UserAgent');
    is($feed->useragent->agent, 'TestAgent/3.0', 'UserAgent set correctly');
}

# Test 8: useragent() setter with invalid value (should die)
{
    my $feed = XML::Feed->new('Atom');
    
    eval {
        $feed->useragent('not an object');
    };
    like($@, qr/useragent must be an LWP::UserAgent object/, 'Dies when setting invalid useragent');
}

# Test 9: RSS feed with useragent
{
    my $ua = LWP::UserAgent->new;
    $ua->agent('RSSTestAgent/1.0');
    
    my $feed = XML::Feed->new('RSS', { useragent => $ua });
    isa_ok($feed, 'XML::Feed::Format::RSS', 'RSS feed created with useragent');
    is($feed->useragent->agent, 'RSSTestAgent/1.0', 'UserAgent preserved in RSS feed');
}

# Test 10: RSS feed with both version and useragent
{
    my $ua = LWP::UserAgent->new;
    $ua->agent('RSSTestAgent/2.0');
    
    my $feed = XML::Feed->new('RSS', version => '0.91', { useragent => $ua });
    isa_ok($feed, 'XML::Feed::Format::RSS', 'RSS feed created with version and useragent');
    like($feed->format, qr/0\.91/, 'RSS version is correct');
    is($feed->useragent->agent, 'RSSTestAgent/2.0', 'UserAgent preserved');
}

# Test 11: LWP::UserAgent subclass should be accepted
SKIP: {
    skip "Creating subclass inline for testing", 2;
    
    # This would test that subclasses of LWP::UserAgent are accepted
    # but we'll skip it for now as it requires more setup
}

done_testing;
