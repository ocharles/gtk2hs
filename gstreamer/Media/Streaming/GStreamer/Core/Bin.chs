-- GIMP Toolkit (GTK) Binding for Haskell: binding to gstreamer   -*-haskell-*-
--
--  Author : Peter Gavin
--  Created: 1-Apr-2007
--
--  Version $Revision$ from $Date$
--
--  Copyright (c) 2007 Peter Gavin
--
--  This library is free software; you can redistribute it and/or
--  modify it under the terms of the GNU Library General Public
--  License as published by the Free Software Foundation; either
--  version 2 of the License, or (at your option) any later version.
--
--  This library is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
--  Library General Public License for more details.
--
module Media.Streaming.GStreamer.Core.Bin (
  
  Bin,
  BinClass,
  castToBin,
  toBin,
  fromBin,
  binAdd,
  binRemove,
  binGetByName,
  binGetByNameRecurseUp,
  binGetByInterface,
  binIterateElements,
  binIterateRecurse,
  binIterateSinks,
  binIterateSorted,
  binIterateSources,
  binIterateAllByInterface,
  binFindUnconnectedPad,
  
  onBinElementAdded,
  afterBinElementAdded,
  onBinElementRemoved,
  afterBinElementRemoved
  
  ) where

import Control.Exception                      ( bracket_ )
import Control.Monad                          ( liftM )
import System.Glib.FFI
{#import System.Glib.GType#}                  ( GType )
import System.Glib.UTFString                  ( withUTFString )
import System.Glib.GList                      ( GList
                                              , readGList )
{#import Media.Streaming.GStreamer.Core.Types#}
{#import Media.Streaming.GStreamer.Core.Signals#}

{# context lib = "gstreamer" prefix = "gst" #}

binAdd :: (BinClass bin,
           ElementClass element) =>
          bin
       -> element
       -> IO Bool
binAdd bin element =
    liftM toBool $ {# call bin_add #} (toBin bin) (toElement element)

binRemove :: (BinClass bin,
              ElementClass element) =>
             bin
          -> element
          -> IO Bool
binRemove bin element =
    liftM toBool $ {# call bin_remove #} (toBin bin) (toElement element)

binGetByName :: BinClass bin =>
                bin
             -> String
             -> IO (Maybe Element)
binGetByName bin name =
    withUTFString name ({# call bin_get_by_name #} (toBin bin)) >>= maybePeek newElement

binGetByNameRecurseUp :: BinClass bin =>
                bin
             -> String
             -> IO (Maybe Element)
binGetByNameRecurseUp bin name =
    withUTFString name ({# call bin_get_by_name_recurse_up #} $ toBin bin) >>=
        maybePeek newElement

binGetByInterface :: BinClass bin =>
                     bin
                  -> GType
                  -> IO (Maybe Element)
binGetByInterface bin iface =
    {# call bin_get_by_interface #} (toBin bin) (fromIntegral iface) >>=
        maybePeek newElement

binIterateElements :: BinClass bin =>
                      bin
                   -> IO (Maybe (Iterator Element))
binIterateElements bin =
    {# call bin_iterate_elements #} (toBin bin) >>=
        maybePeek newIterator

binIterateRecurse :: BinClass bin =>
                     bin
                  -> IO (Maybe (Iterator Element))
binIterateRecurse bin =
    {# call bin_iterate_recurse #} (toBin bin) >>=
        maybePeek newIterator

binIterateSinks :: BinClass bin =>
                   bin
                -> IO (Maybe (Iterator Element))
binIterateSinks bin =
    {# call bin_iterate_sinks #} (toBin bin) >>=
        maybePeek newIterator

binIterateSorted :: BinClass bin =>
                     bin
                  -> IO (Maybe (Iterator Element))
binIterateSorted bin =
    {# call bin_iterate_sorted #} (toBin bin) >>=
        maybePeek newIterator

binIterateSources :: BinClass bin =>
                     bin
                  -> IO (Maybe (Iterator Element))
binIterateSources bin =
    {# call bin_iterate_sources #} (toBin bin) >>=
        maybePeek newIterator

binIterateAllByInterface :: BinClass bin =>
                            bin
                         -> GType
                         -> IO (Maybe (Iterator Element))
binIterateAllByInterface bin iface =
    {# call bin_iterate_all_by_interface #} (toBin bin) (fromIntegral iface) >>=
        maybePeek newIterator

binFindUnconnectedPad :: BinClass bin =>
                         bin
                      -> PadDirection
                      -> IO (Maybe Pad)
binFindUnconnectedPad bin direction =
    {# call bin_find_unconnected_pad #} (toBin bin) (fromIntegral $ fromEnum direction) >>=
        maybePeek newPad

onBinElementAdded, afterBinElementAdded :: BinClass bin
                                        => bin
                                        -> (Element -> IO ())
                                        -> IO (ConnectId bin)
onBinElementAdded =
    connect_OBJECT__NONE "element-added" False
afterBinElementAdded =
    connect_OBJECT__NONE "element-added" True

onBinElementRemoved, afterBinElementRemoved :: BinClass bin
                                            => bin
                                            -> (Element -> IO ())
                                            -> IO (ConnectId bin)
onBinElementRemoved =
    connect_OBJECT__NONE "element-removed" False
afterBinElementRemoved =
    connect_OBJECT__NONE "element-removed" True