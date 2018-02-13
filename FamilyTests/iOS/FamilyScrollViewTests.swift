import XCTest
@testable import Family

class FamilyScrollViewTests: XCTestCase {
  static let mockFrame = CGRect(origin: .zero, size: CGSize(width: 500, height: 1000))
  let superview = UIView(frame: FamilyScrollViewTests.mockFrame)
  var scrollView: FamilyScrollView!

  override func setUp() {
    super.setUp()
    scrollView = FamilyScrollView()
  }

  override func tearDown() {
    super.tearDown()
    superview.subviews.forEach { $0.removeFromSuperview() }
  }

  func testContentSizeObserver() {
    scrollView.frame.size.width = FamilyScrollViewTests.mockFrame.size.width
    superview.addSubview(scrollView)
    var size = CGSize(width: 500, height: 250)
    let mockedScrollView = UIScrollView(frame: CGRect(origin: .zero, size: size))
    mockedScrollView.contentSize = size

    scrollView.contentView.addSubview(mockedScrollView)
    scrollView.layoutViews()

    XCTAssertEqual(mockedScrollView.frame, CGRect(origin: .zero, size: size))

    // Check that the layout algorithm is invoked if the views frame changes.
    size.height = 1500
    mockedScrollView.contentSize = size
    XCTAssertEqual(scrollView.contentSize, size)
  }

  func testCollectionViews() {
    let frame = CGRect(origin: .zero, size: CGSize(width: 500, height: 200))
    let verticalCollectionViewLayout = UICollectionViewFlowLayout()
    verticalCollectionViewLayout.scrollDirection = .vertical
    let verticalCollectionView = UICollectionView(frame: frame, collectionViewLayout: verticalCollectionViewLayout)
    scrollView.contentView.addSubview(verticalCollectionView)

    // Vertical components are allowed to be scrolled when there is only one scroll view in the view heirarcy.
    XCTAssertTrue(verticalCollectionView.isScrollEnabled)

    let horizontalCollectionViewLayout = UICollectionViewFlowLayout()
    horizontalCollectionViewLayout.scrollDirection = .horizontal
    let horizontalCollectionView = UICollectionView(frame: frame, collectionViewLayout: horizontalCollectionViewLayout)
    scrollView.contentView.addSubview(horizontalCollectionView)

    XCTAssertFalse(verticalCollectionView.isScrollEnabled)
    XCTAssertTrue(horizontalCollectionView.isScrollEnabled)

    horizontalCollectionView.removeFromSuperview()
    XCTAssertTrue(verticalCollectionView.isScrollEnabled)
  }

  func testTableViews() {
    let frame = CGRect(origin: .zero, size: CGSize(width: 500, height: 200))
    let tableView = UITableView(frame: frame)
    scrollView.contentView.addSubview(tableView)

    XCTAssertTrue(tableView.isScrollEnabled)

    let anotherTableView = UITableView(frame: frame)
    scrollView.contentView.addSubview(anotherTableView)

    XCTAssertFalse(tableView.isScrollEnabled)
    XCTAssertFalse(anotherTableView.isScrollEnabled)

    anotherTableView.removeFromSuperview()
    XCTAssertTrue(tableView.isScrollEnabled)
  }

  func testLayoutAlgorithm() {
    scrollView.frame.size.width = FamilyScrollViewTests.mockFrame.size.width
    superview.addSubview(scrollView)

    XCTAssertEqual(scrollView.contentSize, .zero)
    // Should set the same height as the super view.
    XCTAssertEqual(superview.bounds, scrollView.frame)

    let size = CGSize(width: 500, height: 250)
    let mockedScrollView1 = UIScrollView(frame: CGRect(origin: .zero, size: size))
    let mockedScrollView2 = UIScrollView(frame: CGRect(origin: .zero, size: size))
    let mockedScrollView3 = UIScrollView(frame: CGRect(origin: .zero, size: size))
    let mockedScrollView4 = UIScrollView(frame: CGRect(origin: .zero, size: size))

    [mockedScrollView1, mockedScrollView2, mockedScrollView3, mockedScrollView4].forEach {
      $0.contentSize = size
      scrollView.contentView.addSubview($0)
    }

    scrollView.layoutViews()

    XCTAssertEqual(mockedScrollView1.frame, CGRect(origin: .zero, size: size))
    XCTAssertEqual(mockedScrollView2.frame, CGRect(origin: CGPoint(x: 0, y: 250), size: size))
    XCTAssertEqual(mockedScrollView3.frame, CGRect(origin: CGPoint(x: 0, y: 500), size: size))
    XCTAssertEqual(mockedScrollView4.frame, CGRect(origin: CGPoint(x: 0, y: 750), size: size))

    // Check that layout algorithm takes spacing between views into account.

    scrollView.spacingBetweenViews = 10
    scrollView.layoutViews()

    XCTAssertEqual(mockedScrollView1.frame, CGRect(origin: .zero, size: size))
    XCTAssertEqual(mockedScrollView2.frame, CGRect(origin: CGPoint(x: 0, y: 250 + scrollView.spacingBetweenViews), size: size))
    XCTAssertEqual(mockedScrollView3.frame, CGRect(origin: CGPoint(x: 0, y: 500 + scrollView.spacingBetweenViews * 2), size: size))
    XCTAssertEqual(mockedScrollView4.frame, CGRect(origin: CGPoint(x: 0, y: 750 + scrollView.spacingBetweenViews * 3),
                                                   size: CGSize(width: size.width, height: size.height - scrollView.spacingBetweenViews * 3)))

    scrollView.spacingBetweenViews = 0
    scrollView.layoutViews()

    scrollView.setContentOffset(CGPoint(x: 0, y: 250), animated: false)
    scrollView.layoutViews()

    XCTAssertEqual(mockedScrollView1.frame, CGRect(origin: CGPoint(x: 0, y: 250), size: CGSize(width: size.width, height: 0)))
    XCTAssertEqual(mockedScrollView2.frame, CGRect(origin: CGPoint(x: 0, y: 250), size: size))
    XCTAssertEqual(mockedScrollView3.frame, CGRect(origin: CGPoint(x: 0, y: 500), size: size))
    XCTAssertEqual(mockedScrollView4.frame, CGRect(origin: CGPoint(x: 0, y: 750), size: size))

    scrollView.setContentOffset(CGPoint(x: 0, y: 500), animated: false)
    scrollView.layoutViews()

    XCTAssertEqual(mockedScrollView1.frame, CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: size.width, height: 0)))
    XCTAssertEqual(mockedScrollView2.frame, CGRect(origin: CGPoint(x: 0, y: 500), size: CGSize(width: size.width, height: 0)))
    XCTAssertEqual(mockedScrollView3.frame, CGRect(origin: CGPoint(x: 0, y: 500), size: size))
    XCTAssertEqual(mockedScrollView4.frame, CGRect(origin: CGPoint(x: 0, y: 750), size: size))

    scrollView.setContentOffset(CGPoint(x: 0, y: 750), animated: false)
    scrollView.layoutViews()

    XCTAssertEqual(mockedScrollView1.frame, CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: size.width, height: 0)))
    XCTAssertEqual(mockedScrollView2.frame, CGRect(origin: CGPoint(x: 0, y: 250), size: CGSize(width: size.width, height: 0)))
    XCTAssertEqual(mockedScrollView3.frame, CGRect(origin: CGPoint(x: 0, y: 750), size: CGSize(width: size.width, height: 0)))
    XCTAssertEqual(mockedScrollView4.frame, CGRect(origin: CGPoint(x: 0, y: 750), size: size))
  }
}
