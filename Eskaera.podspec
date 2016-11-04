Pod::Spec.new do |s|

  s.name         = "Eskaera"
  s.version      = "2.0.0"
  s.summary      = "Swift library to enqueue and execute RESTfull HTTP requests."
  s.description  = <<-DESC
                   This library can be used to persist queue HTTP requests avoiding
                   duplicate requests that are already in process.
                   It also provides the ability to persist enqueue failed requests to be re-tried.
                   DESC
  s.homepage     = "https://github.com/victorrodri04/Eskaera"
  s.license      = { type: 'MIT', file: 'LICENSE' }
  s.author       = { "Victor Rodriguez" => 'victorrodri04@gmail.com', "Sergio Fernández" => 'fdzsergio@gmail.com' }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/victorrodri04/Eskaera.git", :tag => s.version }
  s.source_files = "Eskaera", "Eskaera/**/*.{h,swift}"

end
