package at.bestsolution.jfr

import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.emf.common.util.URI
import at.bestsolution.jfr.jFRMeta.Model

import static extension at.bestsolution.jfr.GenUtil.*
import java.util.HashMap
import java.nio.file.Files
import java.nio.file.StandardOpenOption
import java.nio.file.Paths
import java.util.List
import java.util.Map

class IndexGen {
	def static void main(String[] args) {
		val versions = createVersionList(Integer.parseInt(args.get(0)))
		val injector = new JFRMetaStandaloneSetup().createInjectorAndDoEMFRegistration();
		val resourceSet = injector.getInstance(XtextResourceSet);
		resourceSet.addLoadOption(XtextResource.OPTION_RESOLVE_ALL, Boolean.TRUE);

		val models = new HashMap
		for( v : versions ) {
			val resource = resourceSet.getResource(
			    URI.createURI("file:/Users/tomschindl/git/jfr-doc/openjdk-"+v+".jfr"), true);
			val model = resource.getContents().head as Model;
			models.put(v,model)
		}

		Files.writeString(Paths.get("/Users/tomschindl/git/jfr-doc/index.html"),generate(models,versions), StandardOpenOption.TRUNCATE_EXISTING, StandardOpenOption.CREATE)
	}

	def static generate(Map<String,Model> map, List<String> versions) '''
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
						<h1 class="uk-h1">Java Flight Recorder Events</h1>
						<p>
							Starting with OpenJDK-11 Java Flight Recorder Events are available to monitor your running JVM. A matrix of all
							events available in different OpenJDK Versions is available <a href="openjdk-matrix.html">here</a>.
						</p>

			            <table class="uk-table uk-table-hover uk-table-divider uk-table-small">
			                <caption>Version Overview</caption>
			                <thead>
			                    <tr>
			                        <th>Version</th>
			                        <th>Events</th>
			                        <th>Types</th>
			                    </tr>
			                </thead>
			                <tbody>
								«FOR v : versions»
									<tr>
										<td><a href="openjdk-«v».html">OpenJDK «v»</a></td>
										<td>«map.get(v).classes.filter[c|c.super == "jdk.jfr.Event"].size»</td>
										<td>«map.get(v).classes.filter[c|c.super === null].size»</td>
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