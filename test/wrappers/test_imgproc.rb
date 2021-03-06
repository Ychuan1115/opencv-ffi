

require 'test/setup'
require 'opencv-ffi-wrappers/core'
require 'opencv-ffi-wrappers/imgproc'
require 'opencv-ffi-wrappers/misc'

class TestImgprocWrappers < Test::Unit::TestCase

  def setup
        @img = TestSetup::test_image
  end

  def test_getAffineTransform
    src = Array.new(5) { |i|
      CVFFI::Point.new( 1.1, i*1.0 )
    }
    dst = Array.new(5) { |i|
      CVFFI::Point.new( i*1.0, i* -1.0 )
    }

    result = CVFFI::get_affine_transform(src,dst)

    assert_not_nil result

    CVFFI::print_matrix(result, :format => :e)

 end

  def test_warpAffine
    warp = CVFFI::CvMat.new CVFFI::cvCreateMat(2,3,:CV_32F)
    CVFFI::cvSetReal2D(warp, 0,0,1.0)
    CVFFI::cvSetReal2D(warp, 0,1,0.0)
    CVFFI::cvSetReal2D(warp, 0,2,0.0)
    CVFFI::cvSetReal2D(warp, 1,0,0.0)
    CVFFI::cvSetReal2D(warp, 1,1,1.0)
    CVFFI::cvSetReal2D(warp, 1,2,0.0)

    dst = CVFFI::cvCreateImage( @img.image_size.to_CvSize, @img.depth, @img.nChannels ) 

    out = CVFFI::warp_affine( @img.to_IplImage, dst, warp )

    TestSetup::save_image("affineWarped.jpg", dst )

  end


  def corner_common_tests( corners, img, params = nil )

    if params
     assert corners.length <= params.max_corners
    end
   
   # Hm, what can I test?
    corners.each { |c|
      assert c.x >= 0.0
      assert c.x < img.width
      assert c.y >= 0.0
      assert c.y < img.height
    }
  end

  def list_corners( corners, name = "" )
puts "#{name} found #{corners.length} points"
    display = [corners.length, 10].min
    puts "Only listing first #{display} corners" unless display == corners.length
    display.times { |i|
      puts "%d  % 4d, % 4d" % [i, corners[i].x, corners[i].y]
    }
  end

  def save_corners( corners, filename )
    annotated = @img.clone
    corners.each { |corner|
      CVFFI::draw_circle( annotated, corner, { color: CVFFI::CvScalar.new( x: 255, y: 255, z: 0, w: 0 ) } )
    }
    TestSetup::save_image( filename, annotated )
  end


 
  def test_goodFeaturesToTrack_default_params
    corners = CVFFI::goodFeaturesToTrack( @img )
    corner_common_tests( corners, @img )
    list_corners( corners, "Shi-Tomasi" )
    save_corners( corners, "greyscale_shitomasi.jpg" )

    params = CVFFI::GoodFeaturesParams.new( use_harris: true )
    harris_corners = CVFFI::goodFeaturesToTrack( @img, params )
    corner_common_tests( harris_corners, @img, params )
    list_corners( harris_corners, "Harris" )
    save_corners( harris_corners, "greyscale_haris.jpg" )

    assert harris_corners != corners
  end

  def test_goodFeaturesToTrack_shitomasi_with_params
    params = CVFFI::GoodFeaturesParams.new( quality_level: 0.7,
                                        min_distance: 10 )
    corners = CVFFI::goodFeaturesToTrack( @img, params )
    corner_common_tests( corners, @img, params )
  end

  def test_goodFeaturesToTrack_harris_with_params
  end 
  



end
