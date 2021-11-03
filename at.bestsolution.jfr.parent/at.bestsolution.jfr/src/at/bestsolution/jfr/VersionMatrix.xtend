package at.bestsolution.jfr

import java.util.Map

import static extension at.bestsolution.jfr.GenUtil.*
import java.util.HashMap
import java.nio.file.Files
import java.nio.file.StandardOpenOption
import java.nio.file.Paths
import java.util.Set

class VersionMatrix {
	def static void main(String[] args) {

		val models = createModelMap

		val all = models.values.flatMap[m|m.classes].filter[c|c.super == "jdk.jfr.Event"].map[c|c.eventName].toSet;
		val classVersion = new HashMap()

		all.forEach[ v | {
			val versionData = new HashMap()
			models.forEach[key, value |
				versionData.put(key,value.classes.findFirst[c|c.eventName == v] !== null)
			]
			classVersion.put(v,versionData)
		} ]

		Files.writeString(Paths.get("/Users/tomschindl/git/jfr-doc/openjdk-matrix.html"),generate(classVersion,models.keySet), StandardOpenOption.TRUNCATE_EXISTING, StandardOpenOption.CREATE)

	}

	def static generate(Map<String,Map<String,Boolean>> classVersion, Set<String> versions) '''
		<html>
		    <head>
		        <link href="http://fonts.cdnfonts.com/css/source-sans-pro" rel="stylesheet">
		        <!-- UIkit CSS -->
		        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/uikit@3.5.7/dist/css/uikit.min.css" />

		        <!-- UIkit JS -->
		        <script src="https://cdn.jsdelivr.net/npm/uikit@3.5.7/dist/js/uikit.min.js"></script>
		        <script src="https://cdn.jsdelivr.net/npm/uikit@3.5.7/dist/js/uikit-icons.min.js"></script>
		        <style>
		            html {
		                font-family: "Source Sans Pro" !important;
		            }
		            @media (min-width:1400px) {
			            .tm-sidebar-left {
			                width: 300px !important;
			                padding: 45px 45px 60px 20px;
			            }
		            }
		            .tm-sidebar-left {
		                position: fixed;
		                top: 80px;
		                bottom: 0;
		                box-sizing: border-box;
		                width: 240px !important;
		                padding: 40px 40px 60px 20px;
		                border-right: 1px #e5e5e5 solid;
		                overflow: auto;
		            }
		        </style>
		    </head>
		    <body>
		    	«versions.htmlHeader»
				<div class="tm-main uk-section uk-section-default">
					<div class="uk-container uk-container-small uk-position-relative">
			            <table class="uk-table uk-table-hover uk-table-divider uk-table-small">
			                <caption>Event Matrix</caption>
			                <thead>
			                    <tr>
			                        <th>Event</th>
			                        «FOR v : versions»
			                        	<th style="text-align: center !important">«v»</th>
			                        «ENDFOR»
			                    </tr>
			                </thead>
			                <tbody>
								«FOR c : classVersion.keySet.sort»
									<tr>
										<td>«c»</td>
										«FOR v : versions»
											<td style="text-align: center !important">«IF classVersion.get(c).get(v)»<a href="openjdk-«v».html#«c»" class="uk-icon-button" uk-icon="check"></a>«ENDIF»</td>
										«ENDFOR»
									</tr>
								«ENDFOR»
			                </tbody>
			            </table>
			    	</div>
			    	«htmlFooter»
				</div>
		    </body>
		</html>
	'''
}