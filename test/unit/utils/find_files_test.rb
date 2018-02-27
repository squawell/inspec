# encoding: utf-8
# author: Stephan Renatus

require 'helper'

describe FindFiles do
  let (:findfiles) do
    class FindFilesTest
      include FindFiles
      def inspec
        Inspec::Backend.create(backend: :mock)
      end
    end
    FindFilesTest.new
  end

  let(:inspec) { mock }
  let(:result) { mock }
  let(:shim) { findfiles }

  describe '#find_files' do
    it 'returns an empty array when no files are found' do
      shim.expects(:warn)
      shim.find_files('/no/such/mock', type: 'file', depth: 1).must_equal([])
    end
  end

  describe '#find_files_or_warn' do
    before do
      shim.expects(:inspec).returns(inspec)
      result.stubs(:exit_status).returns(0)
      result.stubs(:stdout).returns('mock')
    end

    it 'constructs the correct command' do
      inspec.expects(:command).with("sh -c 'find /foo/bar/'").returns(result)
      shim.find_files('/foo/bar/')
    end

    it 'constructs the correct command when a single quote is in the path' do
      inspec.expects(:command).with(%{sh -c "find /foo/\'bar/"}).returns(result)
      shim.find_files(%{/foo/'bar/})
    end

    it 'constructs the correct command when a double quote is in the path' do
      inspec.expects(:command).with(%{sh -c 'find /foo/\"bar/'}).returns(result)
      shim.find_files(%{/foo/"bar/})
    end
  end
end
