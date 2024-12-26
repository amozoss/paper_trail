# frozen_string_literal: true

require "paper_trail/events/base"

module PaperTrail
  module Events
    # See docs in `Base`.
    #
    # @api private
    class Create < Base
      # Return attributes of nascent `Version` record.
      #
      # @api private
      def data
        # YOLO support for google spanner
        id = if @record.id.is_a?(StringIO)
               @record.id.rewind
               @record.id.read
             elsif @record.id.is_a?(Array)
               @record.id.map do |item|
                 if item.is_a?(StringIO)
                   item.rewind
                   item.read
                 else
                   item
                 end
               end
             else
               @record.id
             end
        data = {
          item_id: id,
          item_type: @record.class.base_class.name,
          event: @record.paper_trail_event || "create",
          whodunnit: PaperTrail.request.whodunnit
        }
        if @record.respond_to?(:updated_at)
          data[:created_at] = @record.updated_at
        end
        if record_object_changes? && changed_notably?
          changes = notable_changes
          data[:object_changes] = prepare_object_changes(changes)
        end
        merge_item_subtype_into(data)
        merge_metadata_into(data)
      end
    end
  end
end
