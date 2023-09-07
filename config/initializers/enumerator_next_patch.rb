# frozen_string_literal: true

# Monkey patch of Enumerator#next to get better stack traces
# when an error is raised from within a Fiber.
# https://bugs.ruby-lang.org/issues/16829
module EnumeratorNextPatch
  %w(next next_values peek peek_values).each do |name|
    define_method(name) do |*args|
      gitlab_patch_backtrace_marker { super(*args) }
    rescue Exception => err # rubocop: disable Lint/RescueException
      err.set_backtrace(err.backtrace + caller) unless
        has_gitlab_patch_backtrace_marker?(err.backtrace) && backtrace_matches_caller?(err.backtrace)

      raise
    end
  end

  private

  def gitlab_patch_backtrace_marker
    yield
  end

  # This function tells us whether the exception was generated by #next itself or by something in
  # the Fiber that it invokes. If it's generated by #next, then the backtrace will have
  # #gitlab_patch_backtrace_marker as the third item down the trace (since
  # #gitlab_patch_backtrace_marker calls a block, which in turn calls #next.) If it's generated
  # by the Fiber that #next invokes, then it won't contain this marker.
  def has_gitlab_patch_backtrace_marker?(backtrace)
    match = %r(^(.*):[0-9]+:in `gitlab_patch_backtrace_marker'$).match(backtrace[2])

    !!match && match[1] == __FILE__
  end

  # This function makes sure that the rest of the stack trace matches in order to avoid missing
  # an exception that was generated by calling #next on another Enumerator inside the Fiber.
  # This might miss some *very* contrived scenarios involving recursion, but exceptions don't
  # provide Fiber information, so it's the best we can do.
  def backtrace_matches_caller?(backtrace)
    backtrace[3..] == caller[1..]
  end
end

Enumerator.prepend(EnumeratorNextPatch)
