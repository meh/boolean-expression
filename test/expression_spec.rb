#! /usr/bin/env ruby
require 'rubygems'
require 'boolean/expression'

describe Boolean::Expression do
	describe '#parse' do
		it 'parses correctly (lol && wut || !(wat && omg && nig))' do
			Boolean::Expression['(lol && wut || !(wat && omg && nig))'].to_s.should == '(lol AND wut OR NOT (wat AND omg AND nig))'
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
end
