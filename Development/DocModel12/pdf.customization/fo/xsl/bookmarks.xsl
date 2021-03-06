<?xml version='1.0'?>

<!-- 
Copyright © 2004-2006 by Idiom Technologies, Inc. All rights reserved. 
IDIOM is a registered trademark of Idiom Technologies, Inc. and WORLDSERVER
and WORLDSTART are trademarks of Idiom Technologies, Inc. All other 
trademarks are the property of their respective owners. 

IDIOM TECHNOLOGIES, INC. IS DELIVERING THE SOFTWARE "AS IS," WITH 
ABSOLUTELY NO WARRANTIES WHATSOEVER, WHETHER EXPRESS OR IMPLIED,  AND IDIOM
TECHNOLOGIES, INC. DISCLAIMS ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING
BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR 
PURPOSE AND WARRANTY OF NON-INFRINGEMENT. IDIOM TECHNOLOGIES, INC. SHALL NOT
BE LIABLE FOR INDIRECT, INCIDENTAL, SPECIAL, COVER, PUNITIVE, EXEMPLARY,
RELIANCE, OR CONSEQUENTIAL DAMAGES (INCLUDING BUT NOT LIMITED TO LOSS OF 
ANTICIPATED PROFIT), ARISING FROM ANY CAUSE UNDER OR RELATED TO  OR ARISING 
OUT OF THE USE OF OR INABILITY TO USE THE SOFTWARE, EVEN IF IDIOM
TECHNOLOGIES, INC. HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. 

Idiom Technologies, Inc. and its licensors shall not be liable for any
damages suffered by any person as a result of using and/or modifying the
Software or its derivatives. In no event shall Idiom Technologies, Inc.'s
liability for any damages hereunder exceed the amounts received by Idiom
Technologies, Inc. as a result of this transaction.

These terms and conditions supersede the terms and conditions in any
licensing agreement to the extent that such terms and conditions conflict
with those set forth herein.

This file is part of the DITA Open Toolkit project hosted on Sourceforge.net. 
See the accompanying license.txt file for applicable licenses.
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:exsl="http://exslt.org/common"
                xmlns:opentopic="http://www.idiominc.com/opentopic"
                xmlns:opentopic-index="http://www.idiominc.com/opentopic/index"
                extension-element-prefixes="exsl"
                exclude-result-prefixes="opentopic-index opentopic"
                version="2.0">

    <xsl:variable name="map" select="//opentopic:map"/>

    <xsl:template name="createBookmarks">
        <xsl:variable name="bookmarks">
            <xsl:apply-templates select="/" mode="bookmark"/>
        </xsl:variable>

        <xsl:if test="count(exsl:node-set($bookmarks)/*) > 0">
            <fo:bookmark-tree>
                <fo:bookmark internal-destination="{$id.toc}">
                    <xsl:if test="$bookmarkStyle!='EXPANDED'">
                        <xsl:attribute name="starting-state">hide</xsl:attribute>
                    </xsl:if>
                    <fo:bookmark-title>
                        <xsl:call-template name="insertVariable">
                            <xsl:with-param name="theVariableID" select="'Table of Contents'"/>
                        </xsl:call-template>
                    </fo:bookmark-title>
                </fo:bookmark>
                <xsl:copy-of select="exsl:node-set($bookmarks)"/>
                <!-- CC #6163  -->
                <xsl:if test="(//opentopic-index:index.groups//opentopic-index:index.entry) and (count($index-entries//opentopic-index:index.entry) &gt; 0) ">
                    <fo:bookmark internal-destination="{$id.index}">
                        <xsl:if test="$bookmarkStyle!='EXPANDED'">
                            <xsl:attribute name="starting-state">hide</xsl:attribute>
                        </xsl:if>
                        <fo:bookmark-title>
                            <xsl:call-template name="insertVariable">
                                <xsl:with-param name="theVariableID" select="'Index'"/>
                            </xsl:call-template>
                        </fo:bookmark-title>
                    </fo:bookmark>
                </xsl:if>
            </fo:bookmark-tree>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/topic ') and not(contains(@class, ' bkinfo/bkinfo '))]" mode="bookmark">
        <xsl:variable name="id" select="@id"/>
        <xsl:variable name="gid" select="generate-id()"/>
        <xsl:variable name="topicNumber" select="count(exsl:node-set($topicNumbers)/topic[@id = $id][following-sibling::topic[@guid = $gid]]) + 1"/>
        <xsl:variable name="topicTitle">
            <xsl:call-template name="getNavTitle">
              <xsl:with-param name="topicNumber" select="$topicNumber"/>
            </xsl:call-template>
        </xsl:variable>
        <!-- normalize the title bug:3065853 -->
        <xsl:variable name="normalizedTitle" select="normalize-space($topicTitle)"/>
        <xsl:variable name="mapTopic">
            <xsl:copy-of select="$map//*[@id = $id]"/>
        </xsl:variable>
        

        <!-- GS 2008-Sept-09: New section -->   
            <xsl:variable name="title" select="$topicTitle" />
            <xsl:variable name="type">
                <!-- Determines the topic type when using bookmaps. The @refclass attribute can be used to determine, e.g., where a chapter or an appendix starts. -->
                <xsl:call-template name="f_toc_getTocEntryType">
                <!-- The f_toc_getTocEntryType template is defined in the customized toc.xsl file. -->
                    <xsl:with-param name="class">
                        <xsl:value-of select="//*[descendant-or-self::*[@id = $id]]/@class"/>
                    </xsl:with-param>
                    <xsl:with-param name="refclass">
                        <xsl:value-of select="//*[descendant-or-self::*[@id = $id]]/@refclass"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="fsTocType">
            <!-- Maps the DITA standard topic type to a Fujitsu-specific topic type. Required to identify and handle the glossary. -->
                <xsl:call-template name="f_toc_mapTocEntryType">
                <!-- The f_toc_mapTocEntryType template is defined in the customized toc.xsl file. -->
                    <xsl:with-param name="type" select="$type"/>
                    <xsl:with-param name="title" select="$title"/>
                </xsl:call-template>
            </xsl:variable>
        <!--    <xsl:message>fsTocType: <xsl:value-of select="$fsTocType"/></xsl:message> -->
            
            <xsl:variable name="space" select="' '"/>
            <!-- A space character needs to be inserted between the number and the topic title. --> 
            
            <xsl:variable name="level" select="count(ancestor::*[contains(@class,' topic/topic ')])"/>
            <!--Required to differentiate between processing top-level topics and subordinate topics. -->
            
            
            <xsl:variable name="number">
            <!-- Generates numbers for chapters and appendixes -->
                <xsl:choose>
                    <xsl:when test="$fsTocType = 'preface' ">
                    </xsl:when>
                    <xsl:when test="$fsTocType = 'glossary' ">
                    </xsl:when>
                    <xsl:when test="$fsTocType = 'chapter' ">
                        <xsl:value-of select="exsl:node-set($fs_topicNumbers)//*[@id = $id]/@number"/>
                    </xsl:when>
                    <xsl:when test="$fsTocType = 'appendix' ">
                        <xsl:value-of select="exsl:node-set($fs_topicNumbers)//*[@id = $id]/@number"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message>Unknown fsTocType:<xsl:value-of select="$fsTocType"/></xsl:message>  
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
        <!-- GS 2008-Sept-09: end of new section -->    

        <!-- added by William on 2009-05-11 for toc bug start -->
        <xsl:choose>
        	<xsl:when test="($mapTopic/*[position() = $topicNumber][@toc = 'yes' or not(@toc)]) or (not($mapTopic/*))">

                <!-- jko: 2006-04-21 new -->
                <!-- Exclude chapters without a title from bookmarks -->
                <xsl:if test="normalize-space($topicTitle) != ''">
                <!-- end -->

                    
                    <xsl:variable name="bookmarkNumber">
                        <xsl:choose>
                            <xsl:when test="$level = 0">
                                <xsl:call-template name="insertVariable">
                                    <xsl:with-param name="theVariableID" select="concat('bookmark.', $fsTocType, '.number')"/>
                                    <xsl:with-param name="theParameters">
                                        <number>
                                            <xsl:value-of select="$number"/>
                                        </number>
                                    </xsl:with-param>
                                    </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
    			                <xsl:value-of select="$number"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    
            		<fo:bookmark>
              		  <xsl:attribute name="internal-destination">
              		      <xsl:call-template name="generate-toc-id"/>
              		  </xsl:attribute>
                        <xsl:if test="$bookmarkStyle!='EXPANDED'">
                            <xsl:attribute name="starting-state">hide</xsl:attribute>
                        </xsl:if>
                		<fo:bookmark-title>
                		    <xsl:value-of select="$bookmarkNumber"/>
                		    <xsl:if test="normalize-space($bookmarkNumber) != ''">
                		        <xsl:value-of select="$space"/>
                		    </xsl:if>
                		    <xsl:value-of select="$normalizedTitle"/>
                		</fo:bookmark-title>
                		<xsl:apply-templates mode="bookmark"/>
            		</fo:bookmark>
                </xsl:if>

        	</xsl:when>
        	<xsl:otherwise>
        		<xsl:apply-templates mode="bookmark"/>
        	</xsl:otherwise>
        </xsl:choose>
        <!-- added by William on 2009-05-11 for toc bug end -->
    </xsl:template>

    <xsl:template match="*" mode="bookmark">
        <xsl:apply-templates mode="bookmark"/>
    </xsl:template>

    <xsl:template match="text()" mode="bookmark"/>

</xsl:stylesheet>
