
require 'opencv-ffi/core/library'
require 'opencv-ffi/core/types'

module CVFFI

  attach_function :cvCreateMemStorage, [ :int ], CvMemStorage.typed_pointer
  attach_function :cvCreateSeq, [:int, :int, :int, :pointer ], CvSeq.typed_pointer

  attach_function :cvReleaseMemStorage, [:pointer], :void

  attach_function :cvGetSeqElem, [ :pointer, :int ], :pointer
  attach_function :cvSeqPush, [:pointer, :pointer ], :pointer
  attach_function :cvSeqRemove, [:pointer, :int ], :void

end
