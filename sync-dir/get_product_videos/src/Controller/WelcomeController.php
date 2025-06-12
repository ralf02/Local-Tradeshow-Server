<?php

namespace Drupal\get_product_videos\Controller;

class WelcomeController
{
    public function welcome()
    {
        $contentType = 'product';
        $nids = \Drupal::entityQuery('node')->condition('type', $contentType)->execute();
        $nodes =  \Drupal\node\Entity\Node::loadMultiple($nids);

        foreach ($nodes as $node) {
            if (true) {
            // if ($node->id() == 2921) {
                echo "<pre><hr><h1>{$node->getTitle()}</h1>";
            // $resut = \Drupal::service('macdonmodule.preprocesslayoutbuilder')->preprocessProductHeroLB($r);

                $layout = $node->get('layout_builder__layout')->getValue();

                foreach ($layout as $item) {
                    $section = $item['section'];
                    $section_array = $section->toArray();
                    // echo "<pre>";print_r($section_array["components"]);die;
                    foreach ($section_array["components"] as $component) {
                    // This ID will correspond to the ID we have in the plugin. For example,
                    // the page title block has an ID of "page_title_block".
                        $id = $component["configuration"]["id"];

                        if ($id == 'inline_block:see_it_in_action_block') {
                            $revisionId = $component["configuration"]["block_revision_id"];
                            $c = \Drupal::entityTypeManager()->getStorage('block_content')->loadRevision($revisionId);
                            $p = \Drupal\paragraphs\Entity\Paragraph::load($c->field_see_it_in_action_field->target_id);
                        // $p2 = \Drupal\paragraphs\Entity\Paragraph::load($p->field_videosiia->target_id);
                            $media = \Drupal\media\Entity\Media::load($p->field_videosiia->target_id);
                            // echo "<br>";
                            // print_r($media->field_media_oembed_video->value);
                        }

                        if ($id == 'inline_block:product_hero_fd2') {
                            $revisionId = $component["configuration"]["block_revision_id"];
                            $c = \Drupal::entityTypeManager()->getStorage('block_content')->loadRevision($revisionId);

                            $p = \Drupal\paragraphs\Entity\Paragraph::load($c->field_product_hero_fd2->target_id);
                            $p2 = \Drupal\paragraphs\Entity\Paragraph::load($p->field_hero_fd2_pgh->target_id);
                            $p3 = \Drupal\paragraphs\Entity\Paragraph::load($p2->field_hero_remote_video->target_id);

                            $media = \Drupal\media\Entity\Media::load($p2->field_hero_remote_video->target_id);
                        }

                        if ($id == 'inline_block:product_documents_block') {
                            $revisionId = $component["configuration"]["block_revision_id"];
                        // print_r($component);
                        // print_r($revisionId);

                            $e = \Drupal::entityTypeManager()->getStorage('block_content')->loadRevision($revisionId);
                            $p = \Drupal\paragraphs\Entity\Paragraph::load($e->field_product_documents_block->target_id);
                            $p2 = \Drupal\paragraphs\Entity\Paragraph::load($p->field_document_cards_lb_pgh->target_id);
                            $p3 = \Drupal\paragraphs\Entity\Paragraph::load($p2->field_documents->target_id);
                            $media = \Drupal\media\Entity\Media::load($p3->field_image->target_id);
                            $file = \Drupal\file\Entity\File::load($media->field_media_document->target_id)->getFileUri();

                            // echo "<br>";print_r($file);die;

                        //https://macdon-s3.s3.amazonaws.com/Macdon-Website/s3fs-public/
                        // $media2 = \Drupal\media\Entity\Media::load($media->field_media_document->target_id);
                        }

                        if ($id == 'inline_block:product_specsheets_block') {
                            $revisionId = $component["configuration"]["block_revision_id"];
                            $c = \Drupal::entityTypeManager()->getStorage('block_content')->loadRevision($revisionId);
                            $p = \Drupal\paragraphs\Entity\Paragraph::load($c->field_product_specsheets_block->target_id);

                            foreach ($p->get('field_specsheets_lb_pgh')->getValue() as $file) {
                                $fid = $file['target_id'];
                                $p2 = \Drupal\paragraphs\Entity\Paragraph::load($fid);

                                $media = \Drupal\media\Entity\Media::load($p2->field_excel_sheet->target_id);
                                $filexlsx = \Drupal\file\Entity\File::load($media->field_media_document->target_id)->getFileUri();
                                $xlsx[] = $filexlsx;
                            }
                                // echo "<pre>"; print_r($xlsx);die;
                        }

                        if ($id == 'inline_block:featured_block') {
                            $revisionId = $component["configuration"]["block_revision_id"];
                            $c = \Drupal::entityTypeManager()->getStorage('block_content')->loadRevision($revisionId);
                            $p = \Drupal\paragraphs\Entity\Paragraph::load($c->field_feature_field->target_id);
                            foreach ($p->get('field_feature_gallery')->getValue() as $file) {
                                $fid = $file['target_id'];

                                $p2 = \Drupal\paragraphs\Entity\Paragraph::load($fid);

                                foreach ($p2->field_buttoncontact->getValue() as $value) {
                                    $videoId = explode('&', $value['uri']);
                                    $videoId = $videoId[0];

                                    $srtVideoId = str_replace(array('https://www.youtube.com/watch?v=','https://youtu.be/','https://www.youtube.com/','https://youtube.com/'), '', $videoId);

                                    $srtVideoId = str_replace(array('&t=1s'), '', $srtVideoId);

                                    $aa = array(
                                        'nid' => $fid,
                                        'name' => $videoId,
                                        'file_id' => $srtVideoId,
                                        'content_type' => $contentType,
                                        'file_type' => 'video',
                                    );
                                    echo "<pre>";print_r($aa);
                                }
                            }
                        }
                    }
                }
                // die('end if');
            } //endif
        }

        die;

        return array(
          '#markup' => 'Welcome to our Website "get_product_videos".'
      );
    }
}
