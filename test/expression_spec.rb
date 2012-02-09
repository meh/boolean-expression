#! /usr/bin/env ruby
require 'rubygems'
require 'boolean/expression'

describe Boolean::Expression do
	describe '#parse' do
		it 'parses correctly (lol && wut || !(wat && omg && nig))' do
			Boolean::Expression['(lol && wut || !(wat && omg && nig))'].to_s.should == '(lol AND wut OR NOT (wat AND omg AND nig))'
		end

		it 'parses correctly quoted stuff' do
			Boolean::Expression['("and" or "not")'].to_s.should == '("and" OR "not")'
		end

		it 'raises when names/groups are not separated by logic' do
			expect { Boolean::Expression['lol wut'] }.should raise_error
			expect { Boolean::Expression['lol && (lol wut)'] }.should raise_error
			expect { Boolean::Expression['lol && (lol !wut)'] }.should raise_error

			expect { Boolean::Expression['lol && (lol || !wut)'] }.should_not raise_error
			expect { Boolean::Expression['lol && !(lol && wut)'] }.should_not raise_error
		end

		it 'raises when a parenthesis is unopened' do
			expect { Boolean::Expression['lol)'] }.should raise_error
			expect { Boolean::Expression['(lol)'] }.should_not raise_error
		end

		it 'raises when a parenthesis is not closed' do
			expect { Boolean::Expression['(lol'] }.should raise_error
			expect { Boolean::Expression['(lol)'] }.should_not raise_error
		end
		
		it 'raises when it starts with AND/OR' do
			expect { Boolean::Expression['AND lol'] }.should raise_error
			expect { Boolean::Expression['OR lol'] }.should raise_error

			expect { Boolean::Expression['NOT lol'] }.should_not raise_error
		end
	end

	describe '#evaluate' do
		it 'returns true for (lol && wut || !(wat && omg && nig))[:lol, :wut]' do
			Boolean::Expression['(lol && wut || !(wat && omg && nig))'][:lol, :wut].should == true
		end

		it 'returns false for (lol && !wut)[:lol, wut]' do
			Boolean::Expression['(lol && !wut)'][:lol, :wut].should == false
		end
	end

	describe '#names' do
		it 'returns uniq and compacted elements' do
			Boolean::Expression['tits AND tits AND tits'].names.should == ['tits']
		end
	end
end
